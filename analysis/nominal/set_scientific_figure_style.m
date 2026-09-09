function set_scientific_figure_style(figura)
%SET_SCIENTIFIC_FIGURE_STYLE Sfondo bianco e testi neri prima dell'esportazione.
% Un unico intervento grafico, senza cambiare dati, curve o scale degli assi.
arguments
    figura (1,1) matlab.ui.Figure
end
if isprop(figura,'Theme'), figura.Theme='light'; end
figura.Color='white';
assi=findall(figura,'Type','axes');
for k=1:numel(assi)
    assi(k).Color='white';
    assi(k).XColor='black'; assi(k).YColor='black'; assi(k).ZColor='black';
    assi(k).GridColor=[0.25 0.25 0.25];
end
testi=findall(figura,'Type','text');
set(testi,'Color','black');
legende=findall(figura,'Type','legend');
set(legende,'TextColor','black','Color','white','EdgeColor','black');
barre=findall(figura,'Type','colorbar');
set(barre,'Color','black');
end
