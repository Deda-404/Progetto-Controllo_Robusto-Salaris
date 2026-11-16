"""Esporta relazione e slide esclusivamente dai risultati della configurazione corrente."""
from pathlib import Path
import csv
import json
import math
import re
import shutil
from collections import Counter

ROOT = Path(__file__).resolve().parents[1]
MATLAB = ROOT / "File_di_Funzioni_Progetto-Accorpati"
DATA = MATLAB / "risultati"
GEN = ROOT / "report/generated"
FIG = ROOT / "report/figures/definitiva"
CURRENT = ["LQG", "LQGI", "Hinf1", "Hinf2", "PID", "Mu_A", "Mu_B"]


def read(name):
    with (DATA / (name + ".csv")).open(encoding="utf-8-sig", newline="") as stream:
        return list(csv.DictReader(stream))


def esc(value):
    return str(value).replace("_", r"\_").replace("%", r"\%")


def num(value, digits=3):
    value = float(value)
    if math.isnan(value):
        return "--"
    if math.isinf(value):
        return r"$\infty$"
    return r"\num{" + f"{value:.{digits}g}" + "}"


def percent(value):
    return "0" if abs(float(value))<1e-9 else num(100*float(value))


def table(name, headers, rows, caption, label=None, slide=False):
    lines = [r"\begin{tabular}{" + "l" + "r" * (len(headers) - 1) + r"}\toprule",
             " & ".join(headers) + r"\\\midrule"]
    lines += [" & ".join(map(str, row)) + r"\\" for row in rows]
    lines += [r"\bottomrule\end{tabular}"]
    if not slide:
        lines = [r"\begin{table}[htbp]\centering\small", r"\setlength{\tabcolsep}{4pt}"] + lines
        lines += [r"\caption{" + caption + "}"]
        if label:
            lines += [r"\label{" + label + "}"]
        lines += [r"\end{table}"]
    dest = ROOT / "presentation/generated" if slide else GEN
    (dest / ("finale_" + name + ".tex")).write_text("\n".join(lines) + "\n", encoding="utf-8")


def interval(row, prefix):
    return f'[{num(row[prefix+"_lower"],4)}, {num(row[prefix+"_upper"],4)}]'


def short_status(status):
    return "INC." if status == "INCONCLUDENTE" else status


def robust_rows(data):
    rows = []
    for x in data:
        method = x["MetodoRP"]
        if method == "NP_FAIL":
            rp, source = "0", r"$\mathrm{NP}_r$"
        elif method == "LIMITE_DA_RS":
            rp, source = r"$\leq$" + num(x["RP_r_upper"], 4), "RS"
        else:
            rp, source = interval(x, "RP_r"), r"\texttt{robgain}"
        norm = num(x["NormaNominaleR"], 4) if x["NS"] == "1" else "NS FAIL"
        rows.append([esc(x["Controllore"]), x["Analisi"][0], norm,
                     "PASS" if x["NP_r"] == "1" else "FAIL",
                     interval(x, "RS"), short_status(x["RS"]), rp, short_status(x["RP_r"]), source])
    return rows


def polynomial(coeff):
    coeff=list(coeff)
    degree=len(coeff)-1
    terms=[]
    for i,c in enumerate(coeff):
        power=degree-i
        if c==0:continue
        value=f"{abs(c):.4g}"
        if "e" in value:
            mant,exp=value.split("e");value=mant+r"\cdot10^{"+str(int(exp))+"}"
        if power:value=("" if abs(c)==1 else value)+( "s" if power==1 else "s^{"+str(power)+"}" )
        terms.append(("-" if c<0 else ("+" if terms else ""))+value)
    return "".join(terms)


def main():
    parameters = (MATLAB / "parametri_sea.m").read_text(encoding="utf-8")
    match = re.search(r"^p\.Ts\s*=\s*([0-9]+(?:\.[0-9]+)?)\s*;", parameters, re.MULTILINE)
    if match is None:
        raise ValueError("Soglia p.Ts non trovata in parametri_sea.m")
    ts_limit = float(match[1])
    GEN.mkdir(exist_ok=True); FIG.mkdir(parents=True,exist_ok=True)
    for name in ["famiglia_attuatori","peso_incertezza","robustezza","ras","dieci_impianti",
                 "sensibilita_singoli_parametri","sensibilita_hinf","nominale",
                 "lqg_lqgi_risposte","lqg_lqgi_comando","hinf_disturbi","lineare_nonlineare_lqg"]:
        shutil.copy2(DATA/(name+".png"),FIG)
    info=json.loads((DATA/"riassunto_numerico.json").read_text(encoding="utf-8"))
    assert info['fisica']['m2']==.8 and 'mEE' not in info['fisica']
    weights=read("ordini_peso"); selected=next(x for x in weights if int(x["Ordine"])==info['ordinePeso'])
    values={"TsLimit":f"{ts_limit:g}","ResiduoEquilibrio":num(info["residuoEquilibrio"]),"ErroreJacobiano":num(info["erroreJacobiano"]),
            "ErroreAB":num(info["erroreAB"]),"ErroreLFT":num(info["erroreLFT"]),
            "Copertura":num(selected["MaxNormaNormalizzata"],4),"Holdout":num(selected["MaxNormaIndipendente"],4),
            "PesoFormula":r"\frac{"+polynomial(info["pesoNum"])+"}{"+polynomial(info["pesoDen"])+"}",
            "CARELQG":num(info["CARE"][0]),"CARELQGI":num(info["CARE"][1]),
            "ScartoMixsyn":num(info["scartoMixsyn"]),"OrdinePeso":str(info['ordinePeso']),
            "GammaMix":num(info['gammaHinf'][0],6),"GammaPID":num(info['gammaHinf'][3],6),
            "Separazione":num(info['separazione']),"DkA":num(info['obiettivoDK'][0],4),"DkB":num(info['obiettivoDK'][1],4),
            "Occorrenze":str(sum(x['Occurrences'] for x in info['blocchiA'])),
            "AlphaLqr":num(info['alphaLqr'],4),"AlphaKalman":num(info['alphaKalman'],4),
            "RapportoKalman":num(info['alphaKalman']/info['alphaLqr'],4)}
    table("carico",[r"$m_2$ [kg]",r"$m_2/\bar m_2$",r"$M_{11}$ [kg m$^2$]",r"$\|K_g\|_2$"],
          [[num(x["Massa2kg"]),num(x["RapportoNominale"]),num(x["M11"]),num(x["NormaKg"],4)] for x in read("candidati_massa")],
          "Massa nominale e due estremi dell'incertezza del secondo link nella configurazione verticale.","tab:carico")
    table('campioni_fisici',['Impianto',r'$\omega_{n1}$',r'$\omega_{n2}$',r'$\tau_{d1}$',r'$\tau_{d2}$',r'$m_2$'],
          [[str(j)]+[num(x[k],4) for k in ['wn1','wn2']]+[num(1000*float(x[k]),4) for k in ['td1','td2']]+[num(x['m2'],4)]
           for j,x in enumerate(read('parametri_dieci_impianti'),1)],
          'Dieci impianti fisici comuni, seed 20261101. Frequenze in rad/s, ritardi in ms e massa in kg; smorzamento 0.8 noto.')
    table("ritardo",["Tolleranza",r"$\|G_p-G_0\|_\infty$",r"Scarto di fase a 40 rad/s [$^\circ$]"],
          [[num(100*float(x["Tolleranza"]))+r"\%",num(x["ScartoAdditivo"],4),num(x["ScartoFase40deg"])] for x in read("candidati_ritardo")],
          "Variazione del solo ritardo verso l'estremo superiore; frequenza naturale e smorzamento nominali.")
    table("pesi",["Ordine",r"$\max\|E_j/W_A\|_\infty$","Eccesso mediano","30 casi indipendenti"],
          [[x["Ordine"],num(x["MaxNormaNormalizzata"],4),num(x["EccessoMediano"],4),num(x["MaxNormaIndipendente"],4)] for x in weights],
          f"Copertura continua dei {info['numeroFit']} casi di costruzione e verifica indipendente. Selezionato l'ordine {info['ordinePeso']}.")
    # Un solo elemento per ciascuna coppia di poli complessi coniugati.
    poles=[]
    for real,im in sorted(zip(info["poliRe"],info["poliIm"]),reverse=True):
        if im < -1e-8:continue
        label=num(real,4) if abs(im)<1e-8 else num(real,4)+r" $\pm j$ "+num(abs(im),4)
        poles.append([label,"instabile" if real>0 else "stabile"])
    table("poli",[r"Poli meccanici [s$^{-1}$]","Esito"],poles,"Poli degli otto stati meccanici al carico nominale; le righe complesse rappresentano coppie coniugate.","tab:poli")
    table("kalman",[r"Fattore $\sigma$",r"Polo lento [s$^{-1}$]","Errore RMS [rad]","Comando RMS [N m]"],
          [[num(x[k]) for k in ["FattoreSigmaAssunta","PoloOsservatore","ErroreStimaRMS","ComandoRMS"]] for x in read("kalman")],
          "Sensibilità del Kalman a sequenza di rumore identica, senza riferimento né disturbo. Intensità assunte, non stimate da misure.")
    hinf=read("hinf")
    methods={"Hinf1":r"\texttt{hinfsyn} 1-DoF", "Hinf2":r"\texttt{hinfsyn} 2-DoF",
             "PID_nuovo":r"\texttt{hinfstruct} 2-DoF"}
    table("hinf",["Controllore","Sintesi","Ordine","Norma comune",r"$\|T_{v\to u}\|_\infty$"],
          [[esc(x["Controllore"].replace("_nuovo","")),methods[x["Controllore"]],x["Ordine"],
            num(x["NormaComune"],4),num(x["GuadagnoRumoreComando"])] for x in hinf],
          "Risultati in frequenza sul nominale. Tutte le chiusure sono internamente stabili.",
          "tab:cap8-norme")
    robust=read("confronto_robusto_r")
    assert len(robust) == 14 and all(x["Mappa"] == "Tzr_v1" for x in robust)
    caption=(r"Post-analisi sul solo riferimento. La norma è quella di $T_{zr}$ sul nominale. "
             r"L'ultima colonna indica da dove proviene il margine $\mathrm{RP}_r$.")
    if any(x["RS"] == "INCONCLUDENTE" or x["RP_r"] == "INCONCLUDENTE" for x in robust):
        caption += " INC. indica un esito inconcludente."
    headers=["Controllore","A/B",r"Norma $r$",r"$\mathrm{NP}_r$","Intervallo RS","RS",
             r"Margine $\mathrm{RP}_r$",r"$\mathrm{RP}_r$","Origine"]
    table("robustezza",headers,robust_rows([x for x in robust if x["Controllore"] in CURRENT]),
          caption,"tab:cap9-robustezza")
    dk=[]
    for i,name in enumerate(["A","B"],1):
        for x in read(f"dk_{i}"):
            dk.append([name,x["Iterazione"],num(x["PeakMu"],4),num(x["GammaScalata"],4),x["Ordine"]])
    table("dk",["Sintesi","Iterazione",r"Picco $\mu$",r"$\gamma$ scalata","Ordine K"],dk,
          "Risultati dei passi D e K con gli stessi pesi e la stessa inizializzazione.",
          "tab:cap9-dk")
    table("riesame_mu",["Modello","Passo","Ordine","Norma comune",r"Errore DC [\%]","Guadagno rumore"],
          [[{"1":"A","2":"B"}[x["Modello"]],x["Iterazione"],x["Ordine"],
            num(x["NormaComune"],4),percent(x["ErroreDC"]),num(x["GuadagnoRumore"],4)] for x in read("riesame_mu")],
          "Riesame sulla stessa pianta nominale. Il passo 1 usa il controllore iniziale comune.",
          "tab:cap9-riesame")
    ras=read("ras"); plants=read("dieci_impianti"); noise=read("rumore")
    states=["CONVERGENZA","MANCATA_CONVERGENZA","DIVERGENZA_OSSERVATA","TIMEOUT","ERRORE_NUMERICO"]
    rasrows=[]; plantrows=[]; timerows=[]; disturbrows=[]; noiserows=[]; loadrows=[]
    load=read("massa_nonlineare")
    finalrows=[]; settling_results={}
    for name in CURRENT:
        counts=Counter(x["Esito"] for x in ras if x["Controllore"]==name)
        assert sum(counts.values())==15 and set(counts).issubset(states)
        rasrows.append([esc(name)]+[counts[s] for s in states])
        physical=[x for x in plants if x["Controllore"]==name and int(x["Impianto"])>0]
        stable=[x for x in physical if x["Stabile"]=="1"]
        def maximum(key,scale=1):
            value=scale*max((float(x[key]) for x in stable),default=float("nan"))
            return "0" if key=="ErroreDC" and abs(value)<1e-9 else num(value,4)
        plantrows.append([esc(name),f"{len(stable)}/10",maximum("ErroreDC",100),maximum("PiccoComando"),maximum("PiccoDisturboRad",180/math.pi)])
        n=next(x for x in plants if x["Controllore"]==name and x["Impianto"]=="0")
        settled = n["Stabile"] == "1" and float(n["Assestamento"]) <= ts_limit
        settling_results[name] = "PASS" if settled else "FAIL"
        ok = (settled and float(n["OvershootPercent"]) <= 15
              and float(n["ErroreDC"]) <= .05 and float(n["Cross"]) <= .25)
        timerows.append([esc(name),num(n["Assestamento"]),settling_results[name],
                         num(n["OvershootPercent"]),percent(n["ErroreDC"]),
                         num(100*float(n["Cross"])),"PASS" if ok else "FAIL"])
        rb=[x for x in robust if x['Controllore']==name]
        assert [row["Analisi"][0] for row in rb] == ["A", "B"] and rb[0]["NP_r"] == rb[1]["NP_r"]
        finalrows.append([esc(name),'PASS' if ok else 'FAIL','PASS' if rb[0]['NP_r']=='1' else 'FAIL',
                          '/'.join(short_status(x['RS']) for x in rb),
                          '/'.join(short_status(x['RP_r']) for x in rb)])
        disturbrows.append([esc(name),num(180/math.pi*float(n["PiccoDisturboRad"])),num(n["RecuperoDisturbo"]),maximum("RecuperoDisturbo")])
        v=next(x for x in noise if x["Controllore"]==name)
        noiserows.append([esc(name),num(v["PiccoCampioni"],4),num(v["PiccoTraCampioni"],4),num(v["RMSIntegrato"],4)])
        loads=sorted([x for x in load if x["Controllore"]==name],key=lambda x:float(x["Massa2"]))
        loadrows.append([esc(name)]+[num(100*float(x["ErroreFinale"])) if x["Completato"]=="1" else "arresto" for x in loads])
        tag=name.replace("_", "").replace("1", "One").replace("2", "Two")
        values.update({tag+"Stable":str(len(stable)),tag+"Conv":str(counts["CONVERGENZA"]),tag+"Peak":num(v["PiccoTraCampioni"],3),tag+"Rms":num(v["RMSIntegrato"],3),tag+"Ts":num(n["Assestamento"]),tag+"Ess":percent(n["ErroreDC"])})
        values.update({tag+'Mp':num(n['OvershootPercent']),tag+'Cross':num(100*float(n['Cross'])),
                       tag+'TrackPeak':num(n['PiccoComando']),tag+'Target':'PASS' if ok else 'FAIL'})
        values.update({tag+'NonConv':str(counts['MANCATA_CONVERGENZA']),
                       tag+'Div':str(counts['DIVERGENZA_OSSERVATA'])})
        for x in robust:
            if x["Controllore"]==name:
                a=x["Analisi"][0]
                values[tag+"RS"+a]=num(x["RS_lower"],4)
                values[tag+"RSesito"+a]=x["RS"]
                values[tag+"RPesito"+a]=x["RP_r"]
                values[tag+"Norma"]=num(x["NormaNominaleRD"],4)
                values[tag+"NormaR"]=num(x["NormaNominaleR"],4)
                values[tag+"IntervalloRPR"+a]=interval(x,"RP_r")
                values[tag+"Ordine"]=x["Ordine"]
                values[tag+'OrdineChiuso']=str(14+int(x['Ordine']))
                values[tag+'IntervalloRS'+a]=interval(x,'RS')
                values[tag+'Frequenza'+a]=num(x['FrequenzaCritica'],4)
    table('confronto_finale',['Controllore','Target nominali',r'$\mathrm{NP}_r$','RS A/B',r'$\mathrm{RP}_r$ A/B'],finalrows,
          r'Target temporali, stabilità robusta e costo pesato del solo riferimento. Gli intervalli dei margini sono nel Capitolo 9.')
    table('frequenze',['Controllore','A/B',r'$\omega_{RS}$ [rad/s]'],
          [[esc(x['Controllore']),x['Analisi'][0],num(x['FrequenzaCritica'],4)] for x in robust],
          'Frequenze critiche restituite dall\'analisi di stabilità robusta dello stesso controllore su A e B.')
    table("ras",["Controllore","Conv.","Non conv.","Allont.","Timeout","Errore"],rasrows,
          "Quindici condizioni iniziali per controllore. Gli esiti numerici restano separati dall'attrazione osservata.")
    table("impianti",["Controllore","Stabili",r"Errore DC [\%]","Picco u [N m]",r"Picco $q_d$ [$^\circ$]"],plantrows,
          "Dieci impianti comuni: massimi sui soli casi stabili. Errore DC relativo e coppia link di 0.5 N m.")
    table("temporali",["Controllore",r"$T_s$ [s]",r"Esito $T_s$",r"$M_p$ [\%]",r"$e_{ss}$ [\%]",r"Cross [\%]","Esito congiunto"],timerows,
          r"Nominale corrente: target simultanei \FinTsLimit\ s, 15\%, 5\%, 25\%. Il tempo di assestamento è misurato rispetto al valore finale, l'errore DC rispetto al riferimento.")
    table("disturbo",["Controllore",r"Picco $q_d$ [$^\circ$]","Recupero nom. [s]","Recupero max [s]"],disturbrows,
          "Coppie link separate: peggiore asse nominale e massimo fra campioni stabili. Infinito indica mancato rientro entro 0.5 gradi nell'orizzonte di 12 s.")
    table("rumore",["Controllore","Picco a 2 ms","Picco fra campioni","RMS integrato"],noiserows,
          "Comando in N m: rumore encoder comune, ZOH 2 ms, 4 s. Picchi osservati senza saturazione; RMS medio fra canali.")
    table("carico_nonlineare",["Controllore","0.72 kg","0.8 kg","0.88 kg"],loadrows,
          r"Errore finale non lineare relativo [\%] a 12 s, riferimento di 5 gradi al primo giunto; drive nominali. Non è una misura asintotica.")
    # Tabelle compatte per le slide: un'unica fonte numerica.
    table("slide_hinf",["Soluzione","Ordine","Norma comune"],
          [[esc(x["Controllore"].replace("_nuovo","")),x["Ordine"],num(x["NormaComune"],4)] for x in hinf],"",slide=True)
    table("slide_rs",["Controllore","A","B"],
          [[esc(name)]+[num(next(x["RS_lower"] for x in robust if x["Controllore"]==name and x["Analisi"].startswith(a)),4) for a in ["A","B"]] for name in CURRENT],"",slide=True)
    table("slide_esiti",["Controllore",r"$T_s$","NS",r"Norma $r$",r"$\mathrm{NP}_r$","RS A/B",r"$\mathrm{RP}_r$ A/B"],
          [[esc(name),settling_results[name],"PASS" if all(x["NS"]=="1" for x in robust if x["Controllore"]==name) else "FAIL",
            num(next(x["NormaNominaleR"] for x in robust if x["Controllore"]==name),4),
            "PASS" if next(x for x in robust if x["Controllore"]==name)["NP_r"]=="1" else "FAIL"]+
            ["/".join(short_status(x[key]) for x in robust if x["Controllore"]==name)
             for key in ["RS","RP_r"]] for name in CURRENT],"",slide=True)
    table("slide_carico",["Controllore","0.72 kg","0.8 kg","0.88 kg"],loadrows[:2],"",slide=True)
    tex="\n".join(r"\newcommand{\Fin"+name+"}{"+value+"}" for name,value in values.items())+"\n"
    (GEN/"finale_values.tex").write_text(tex,encoding="utf-8")
    (ROOT/"presentation/generated/finale_values.tex").write_text(tex,encoding="utf-8")
    print("Tabelle, macro e figure esportate dai dati correnti.")


if __name__=="__main__":
    main()
