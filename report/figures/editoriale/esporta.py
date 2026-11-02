"""Figure editoriali da dati salvati: nessuna sintesi o simulazione.

Esecuzione dalla radice: python report/figures/editoriale/esporta.py.
Richiede numpy, scipy e matplotlib soltanto per l'esportazione della relazione.
Gli ingressi in risultati/ sono aperti esclusivamente in lettura.
"""
from pathlib import Path
import csv
import numpy as np
from scipy.io import loadmat
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[3]
DATA = ROOT / 'File_di_Funzioni_Progetto-Accorpati' / 'risultati'
OUT = Path(__file__).resolve().parent
NAMES = ['LQG', 'LQGI', 'Hinf1', 'Hinf2', 'PID', 'Mu_A', 'Mu_B']
plt.rcParams.update({'font.size': 11, 'axes.grid': True,
                     'grid.alpha': .23, 'savefig.dpi': 180})


def save(fig, name):
    fig.tight_layout()
    fig.savefig(OUT / name, bbox_inches='tight', facecolor='white')
    plt.close(fig)


def field(obj, key):
    return obj[key] if isinstance(obj, dict) else getattr(obj, key)


def export():
    model = loadmat(DATA / 'modello.mat', simplify_cells=True)['modello']
    poles = np.linalg.eigvals(np.asarray(model['Am'], dtype=float))
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.scatter(poles.real, poles.imag, marker='x', s=60, color='#126c87')
    ax.axvline(0, color='black', lw=.8)
    ax.set(xlabel='Parte reale [1/s]', ylabel='Parte immaginaria [rad/s]',
           title='Poli degli otto stati meccanici, con carico nominale')
    save(fig, 'poli_meccanici.png')

    responses = loadmat(DATA / 'confronto.mat', simplify_cells=True)['risposte']
    fig, axes = plt.subplots(4, 2, figsize=(8, 9), sharex=True)
    for col in range(2):
        for idx, color in zip([2, 3, 4], ['#14687c', '#c35b20', '#6755a0']):
            y = np.asarray(responses[idx, 0], dtype=float)
            t = np.arange(y.shape[0]) * .002
            for j in range(4):
                scale = 180 / np.pi if j < 2 else 1
                axes[j, col].plot(t, y[:, j, col] * scale,
                                  label=NAMES[idx], color=color)
        for j in range(2):
            axes[j, col].axhline(5 if j == col else 0, color='black', ls=':', lw=1)
        axes[0, col].set_title(f'Gradino sul giunto {col + 1}')
    for j, label in enumerate(['q1 [gradi]', 'q2 [gradi]', 'u1 [N m]', 'u2 [N m]']):
        axes[j, 0].set_ylabel(label)
    axes[0, 0].legend(loc='best', fontsize=8)
    for ax in axes[-1]:
        ax.set_xlabel('Tempo [s]')
    save(fig, 'hinf_tracking_comando.png')

    runs = loadmat(DATA / 'ras.mat', simplify_cells=True)['traiettorie']
    fig, axes = plt.subplots(4, 2, figsize=(8, 9))
    for i, ax in enumerate(axes.flat):
        if i == 7:
            ax.axis('off')
            continue
        run = runs[i, 0]
        t = field(run, 'tempo')
        q = np.asarray(field(run, 'q'), dtype=float) * 180 / np.pi
        ax.plot(t, q[:, 0], label='q1')
        ax.plot(t, q[:, 1], '--', label='q2')
        ax.axhline(5, color='black', ls=':', label='r1 = 5 gradi')
        ax.set(title=NAMES[i], xlabel='Tempo [s]', ylabel='Posizione [gradi]')
    axes[0, 0].legend(fontsize=8)
    save(fig, 'nonlineare_tracking.png')

    for part, indices in enumerate([range(4), range(4, 7)], start=1):
        fig, axes = plt.subplots(len(indices), 2, figsize=(8, 1.9*len(indices)))
        for row, i in enumerate(indices):
            run = runs[i, 1]
            t = field(run, 'tempo')
            q = np.asarray(field(run, 'q'), dtype=float) * 180 / np.pi
            u = np.asarray(field(run, 'u'), dtype=float)
            for j in range(2):
                axes[row, 0].plot(t, q[:, j], '-' if j == 0 else '--', label=f'q{j+1}')
                axes[row, 1].plot(t, u[:, j], '-' if j == 0 else '--', label=f'u{j+1}')
            axes[row, 0].set_ylabel(f'{NAMES[i]}\nq [gradi]')
            axes[row, 1].set_ylabel('u [N m]')
        for ax in axes[0]:
            ax.legend(fontsize=8)
        for ax in axes[-1]:
            ax.set_xlabel('Tempo [s]')
        save(fig, f'nonlineare_disturbo_{part}.png')

    with (DATA / 'rumore.csv').open(encoding='utf-8-sig', newline='') as f:
        rows = list(csv.DictReader(f))
    fig, ax = plt.subplots(figsize=(9, 4))
    x = np.arange(len(rows))
    ax.bar(x-.18, [float(r['PiccoTraCampioni']) for r in rows], .36, label='Picco osservato')
    ax.bar(x+.18, [float(r['RMSIntegrato']) for r in rows], .36, label='RMS integrato')
    ax.set_yscale('log')
    ax.set_xticks(x, NAMES)
    ax.set(ylabel='Comando [N m]', title='Solo encoder: stessa sequenza ZOH, 4 s')
    ax.legend()
    save(fig, 'rumore_confronto.png')

    # Scope già acquisiti: nessuna estrapolazione oltre i due secondi salvati.
    traces = loadmat(DATA / 'simulink.mat', simplify_cells=True)['tracce']
    with (DATA / 'simulink.csv').open(encoding='utf-8-sig', newline='') as f:
        metadata = list(csv.DictReader(f))
    selected = [(i, r) for i, r in enumerate(metadata)
                if r['campione'] == '0' and r['modello'] in
                ['LQG_nonlinear_sim', 'LQGI_nonlinear_sim', 'mu_nonlinear_sim']]
    fig, axes = plt.subplots(len(selected), 2, figsize=(8, 2.1*len(selected)), squeeze=False)
    for row, (i, meta) in enumerate(selected):
        scope = traces[i]['scope']
        for k in [0, 1, 4]:
            item = scope['scope1'][k]
            vals = item['valori']
            axes[row, 0].plot(vals['tempo'], np.asarray(vals['dati'])*180/np.pi,
                              label=item['nome'])
        for item in scope['scope3']:
            vals = item['valori']
            axes[row, 1].plot(vals['tempo'], vals['dati'], label=item['nome'])
        axes[row, 0].set_title(meta['modello']+' — '+meta['controllore'])
        axes[row, 0].set_ylabel('Posizione [gradi]')
        axes[row, 1].set_ylabel('Comando [N m]')
        for ax in axes[row]:
            ax.set_xlabel('Tempo [s]')
            ax.legend(fontsize=8)
    save(fig, 'scope_salvati.png')

    idx = next(i for i, row in enumerate(metadata)
               if row['modello'] == 'Hinf_nonlinear_sim' and row['campione'] == '0')
    scope = traces[idx]['scope']
    fig, axes = plt.subplots(2, 1, figsize=(9, 6), sharex=True)
    for item in scope['scope1']:
        values = item['valori']
        axes[0].plot(values['tempo'], np.asarray(values['dati'])*180/np.pi,
                     label=item['nome'])
    for item in scope['scope8']:
        values = item['valori']
        command = np.asarray(values['dati'], dtype=float)
        if command.shape[0] != len(values['tempo']):
            command = command.T
        assert command.shape == (len(values['tempo']), 2)
        axes[1].plot(values['tempo'], np.max(np.abs(command), axis=1),
                     label=item['nome'])
    axes[0].set_ylabel('Primo giunto [gradi]')
    axes[1].set(ylabel='max(|u1|, |u2|) [N m]', xlabel='Tempo [s]')
    axes[1].set_yscale('symlog', linthresh=.01)
    for ax in axes:
        ax.legend(fontsize=8, ncol=2)
    save(fig, 'scope_hinf_salvati.png')


if __name__ == '__main__':
    export()
