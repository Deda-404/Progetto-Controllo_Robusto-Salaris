"""Esporta la relazione e le slide dai risultati della campagna con carico."""
from pathlib import Path
import csv
import json
import math
import shutil
from collections import Counter

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "File_di_Funzioni_Progetto-Accorpati/risultati"
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


def robust_rows(data):
    rows=[]
    for x in data:
        method=x["MetodoRP"]
        rp = "0 (NP)" if method=="NP_FAIL" else (
            r"$\leq$"+num(x["RP_upper"],4)+" (RS)" if method=="LIMITE_DA_RS" else interval(x,"RP"))
        norm = num(x["NormaNominale"],4) if x["NS"]=="1" else "NS FAIL"
        rows.append([esc(x["Controllore"]),x["Analisi"][0],norm,interval(x,"RS"),rp])
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
    GEN.mkdir(exist_ok=True); FIG.mkdir(parents=True,exist_ok=True)
    for name in ["famiglia_attuatori","peso_incertezza","robustezza","ras","dieci_impianti",
                 "sensibilita_singoli_parametri","sensibilita_hinf","nominale",
                 "lqg_lqgi_risposte","lqg_lqgi_comando","hinf_disturbi","lineare_nonlineare_lqg"]:
        shutil.copy2(DATA/(name+".png"),FIG)
    info=json.loads((DATA/"riassunto_numerico.json").read_text(encoding="utf-8"))
    weights=read("ordini_peso"); selected=next(x for x in weights if x["Ordine"]=="3")
    values={"ResiduoEquilibrio":num(info["residuoEquilibrio"]),"ErroreJacobiano":num(info["erroreJacobiano"]),
            "ErroreAB":num(info["erroreAB"]),"ErroreLFT":num(info["erroreLFT"]),
            "Copertura":num(selected["MaxNormaNormalizzata"],4),"Holdout":num(selected["MaxNormaIndipendente"],4),
            "PesoFormula":r"\frac{"+polynomial(info["pesoNum"])+"}{"+polynomial(info["pesoDen"])+"}",
            "CARELQG":num(info["CARE"][0]),"CARELQGI":num(info["CARE"][1]),
            "ScartoMixsyn":num(info["scartoMixsyn"])}
    table("carico",[r"$m_{EE}$ [kg]",r"$m_{EE}/m_2$",r"$M_{11}$ [kg m$^2$]",r"$\|K_g\|_2$"],
          [[num(x["MassaEEkg"]),num(x["RapportoMassa2"]),num(x["M11"]),num(x["NormaKg"],4)] for x in read("candidati_carico")],
          "Tre masse candidate nella configurazione verticale. Il carico centrale porta la massa distale a 1 kg.","tab:carico")
    table("ritardo",["Tolleranza",r"$\|G_p-G_0\|_\infty$",r"Scarto di fase a 40 rad/s [$^\circ$]"],
          [[num(100*float(x["Tolleranza"]))+r"\%",num(x["ScartoAdditivo"],4),num(x["ScartoFase40deg"])] for x in read("candidati_ritardo")],
          "Variazione del solo ritardo verso l'estremo superiore; frequenza naturale e smorzamento nominali.")
    table("pesi",["Ordine",r"$\max\|E_j/W_A\|_\infty$","Eccesso mediano","30 casi indipendenti"],
          [[x["Ordine"],num(x["MaxNormaNormalizzata"],4),num(x["EccessoMediano"],4),num(x["MaxNormaIndipendente"],4)] for x in weights],
          "Copertura continua dei 29 casi di costruzione e verifica indipendente. Selezionato l'ordine 3.")
    # Un solo elemento per ciascuna coppia di poli complessi coniugati.
    poles=[]
    for re,im in sorted(zip(info["poliRe"],info["poliIm"]),reverse=True):
        if im < -1e-8:continue
        label=num(re,4) if abs(im)<1e-8 else num(re,4)+r" $\pm j$ "+num(abs(im),4)
        poles.append([label,"instabile" if re>0 else "stabile"])
    table("poli",[r"Poli meccanici [s$^{-1}$]","Esito"],poles,"Poli degli otto stati meccanici al carico nominale; le righe complesse rappresentano coppie coniugate.","tab:poli")
    table("kalman",[r"Fattore $\sigma$",r"Polo lento [s$^{-1}$]","Errore RMS [rad]","Comando RMS [N m]"],
          [[num(x[k]) for k in ["FattoreSigmaAssunta","PoloOsservatore","ErroreStimaRMS","ComandoRMS"]] for x in read("kalman")],
          "Sensibilità del Kalman a sequenza di rumore identica, senza riferimento né disturbo. Intensità assunte, non stimate da misure.")
    hinf=read("hinf")
    table("hinf",["Controllore","Ordine","Norma comune",r"$\|T_{v\to u}\|_\infty$"],
          [[esc(x["Controllore"].replace("_nuovo","")),x["Ordine"],num(x["NormaComune"],4),num(x["GuadagnoRumoreComando"])] for x in hinf],
          "Tutti nominalmente stabili. La norma comune include riferimento e disturbo; il rumore è valutato separatamente.")
    robust=read("confronto_robusto")
    assert len(robust)==14
    caption="Margini robusti: soglia unitaria. NP indica esclusione già sul nominale; RS indica un limite superiore dedotto dalla perdita di stabilità. Non sono misure dirette di RP."
    headers=["Controllore","A/B","Norma nominale","Margine RS","Margine RP"]
    table("robustezza",headers,robust_rows([x for x in robust if x["Controllore"] in CURRENT]),caption)
    dk=[]
    for i,name in enumerate(["A","B"],1):
        for x in read(f"dk_{i}"):
            dk.append([name,x["Iterazione"],num(x["PeakMu"],4),num(x["GammaScalata"],4),x["Ordine"]])
    table("dk",["Sintesi","Iterazione",r"Picco $\mu$",r"$\gamma$ scalata","Ordine K"],dk,
          "Stessi pesi e stesso controllore iniziale. Il risultato di sintesi non sostituisce la post-analisi continua.")
    table("riesame_mu",["Modello","Passo","Ordine","Norma comune",r"Errore DC [\%]","Guadagno rumore"],
          [[x["Modello"],x["Iterazione"],x["Ordine"],num(x["NormaComune"],4),percent(x["ErroreDC"]),num(x["GuadagnoRumore"],4)] for x in read("riesame_mu")],
          "Riesame dei candidati D--K: la prima riga di ogni modello è il medesimo punto iniziale. Il guadagno del rumore è una norma, non un picco di coppia.")
    ras=read("ras"); plants=read("dieci_impianti"); noise=read("rumore")
    states=["CONVERGENZA","MANCATA_CONVERGENZA","DIVERGENZA_OSSERVATA","TIMEOUT","ERRORE_NUMERICO"]
    rasrows=[]; plantrows=[]; timerows=[]; disturbrows=[]; noiserows=[]; loadrows=[]
    load=read("carico_nonlineare")
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
        ok=(n["Stabile"]=="1" and float(n["Assestamento"])<=2 and float(n["OvershootPercent"])<=15 and float(n["ErroreDC"])<=.05 and float(n["Cross"])<=.25)
        timerows.append([esc(name),num(n["Assestamento"]),num(n["OvershootPercent"]),percent(n["ErroreDC"]),num(100*float(n["Cross"])),"PASS" if ok else "FAIL"])
        disturbrows.append([esc(name),num(180/math.pi*float(n["PiccoDisturboRad"])),num(n["RecuperoDisturbo"]),maximum("RecuperoDisturbo")])
        v=next(x for x in noise if x["Controllore"]==name)
        noiserows.append([esc(name),num(v["PiccoCampioni"],4),num(v["PiccoTraCampioni"],4),num(v["RMSIntegrato"],4)])
        loads=sorted([x for x in load if x["Controllore"]==name],key=lambda x:float(x["MassaEE"]))
        loadrows.append([esc(name)]+[num(100*float(x["ErroreFinale"])) if x["Completato"]=="1" else "arresto" for x in loads])
        tag=name.replace("_", "").replace("1", "One").replace("2", "Two")
        values.update({tag+"Stable":str(len(stable)),tag+"Conv":str(counts["CONVERGENZA"]),tag+"Peak":num(v["PiccoTraCampioni"],3),tag+"Rms":num(v["RMSIntegrato"],3),tag+"Ts":num(n["Assestamento"]),tag+"Ess":percent(n["ErroreDC"])})
        for x in robust:
            if x["Controllore"]==name:
                a=x["Analisi"][0]
                values[tag+"RS"+a]=num(x["RS_lower"],4)
                values[tag+"RSesito"+a]=x["RS"]
                values[tag+"RPesito"+a]=x["RP"]
                values[tag+"Norma"]=num(x["NormaNominale"],4)
                values[tag+"Ordine"]=x["Ordine"]
    table("ras",["Controllore","Conv.","Non conv.","Allont.","Timeout","Errore"],rasrows,
          "Quindici condizioni iniziali per controllore. Gli esiti numerici restano separati dall'attrazione osservata.")
    table("impianti",["Controllore","Stabili",r"Errore DC [\%]","Picco u [N m]",r"Picco $q_d$ [$^\circ$]"],plantrows,
          "Dieci impianti comuni: massimi sui soli casi stabili. Errore DC relativo e coppia link di 0.5 N m.")
    table("temporali",["Controllore",r"$T_s$ [s]",r"$M_p$ [\%]",r"$e_{ss}$ [\%]",r"Cross [\%]","Target"],timerows,
          r"Nominale con carico: target simultanei 2 s, 15\%, 5\%, 25\%. Il tempo di assestamento è misurato rispetto al valore finale, l'errore DC rispetto al riferimento.")
    table("disturbo",["Controllore",r"Picco $q_d$ [$^\circ$]","Recupero nom. [s]","Recupero max [s]"],disturbrows,
          "Coppie link separate: peggiore asse nominale e massimo fra campioni stabili. Infinito indica mancato rientro entro 0.5 gradi nell'orizzonte di 12 s.")
    table("rumore",["Controllore","Picco a 2 ms","Picco fra campioni","RMS integrato"],noiserows,
          "Comando in N m: rumore encoder comune, ZOH 2 ms, 4 s. Picchi osservati senza saturazione; RMS medio fra canali.")
    table("carico_nonlineare",["Controllore","0.1 kg","0.2 kg","0.3 kg"],loadrows,
          r"Errore finale non lineare relativo [\%] a 12 s, riferimento di 5 gradi al primo giunto; drive nominali. Non è una misura asintotica.")
    # Tabelle compatte per le slide: un'unica fonte numerica.
    table("slide_hinf",["Soluzione","Ordine","Norma comune"],
          [[esc(x["Controllore"].replace("_nuovo","")),x["Ordine"],num(x["NormaComune"],4)] for x in hinf],"",slide=True)
    table("slide_rs",["Controllore","A","B"],
          [[esc(name)]+[num(next(x["RS_lower"] for x in robust if x["Controllore"]==name and x["Analisi"].startswith(a)),4) for a in ["A","B"]] for name in CURRENT],"",slide=True)
    table("slide_esiti",["Controllore","NS","NP","RS A/B","RP A/B"],
          [[esc(name),"PASS" if next(x for x in robust if x["Controllore"]==name)["NS"]=="1" else "FAIL",
            "PASS" if next(x for x in robust if x["Controllore"]==name)["NP"]=="1" else "FAIL"]+
            ["/".join(x[key] for x in robust if x["Controllore"]==name) for key in ["RS","RP"]] for name in CURRENT],"",slide=True)
    table("slide_carico",["Controllore","0.1 kg","0.2 kg","0.3 kg"],loadrows[:2],"",slide=True)
    tex="\n".join(r"\newcommand{\Fin"+name+"}{"+value+"}" for name,value in values.items())+"\n"
    (GEN/"finale_values.tex").write_text(tex,encoding="utf-8")
    (ROOT/"presentation/generated/finale_values.tex").write_text(tex,encoding="utf-8")
    print("Tabelle, macro e otto figure esportate dai dati con carico.")


if __name__=="__main__":
    main()
