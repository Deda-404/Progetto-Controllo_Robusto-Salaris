function paths = plot_m10_lower_lft_diagram
%PLOT_M10_LOWER_LFT_DIAGRAM Schema riproducibile dei soli canali M10 reali.
%   La chiusura inferiore realizza u=K*y; il meno e gia in P22=-G.
root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
m=load(fullfile(root,'results','data','m10_hinfsyn_nominal.mat'));
assert(isequal(size(m.P),[6,4]) && isempty(m.config.W3), ...
    'M10Diagram:Channels','Lo schema e definito per M10 a due pesi.');
assert(isequal(m.partition.controlInputIndices,3:4) && ...
    isequal(m.partition.measurementOutputIndices,5:6), ...
    'M10Diagram:Order','Ordine dei segnali incompatibile con la figura.');
f=figure('Visible','off','Color','white','Position',[100 100 1200 620]);
cleanup=onCleanup(@() close(f));
% P espone w e u a sinistra, z e y a destra, nell'ordine della sintesi.
box([.27 .47 .46 .39],{'P(s): pianta generalizzata M10', ...
    'G: u [N m] -> q [rad]', ...
    'e = r - q;  z_1 = W_1 e;  z_2 = W_2 u', ...
    '6 uscite x 4 ingressi; W_3 assente'});
box([.39 .12 .22 .17],{'K(s)', 'u = K y'});
arrow([.05 .27],[.76 .76]); label([.035 .79 .22 .07],'w = r  (2)');
arrow([.73 .96],[.76 .76]); label([.76 .79 .23 .07],'z = [z_1; z_2]  (4)');
% Il ramo y scende dall'uscita inferiore di P verso l'ingresso di K.
lineSegment([.73 .84],[.54 .54]); lineSegment([.84 .84],[.54 .205]);
arrow([.84 .61],[.205 .205]); label([.76 .40 .23 .07],'y = e  (2)');
% Il ramo u risale dall'uscita di K all'ingresso inferiore di P.
lineSegment([.39 .16],[.205 .205]); lineSegment([.16 .16],[.205 .54]);
arrow([.16 .27],[.54 .54]); label([.03 .40 .15 .07],'u  (2)');
label([.15 .89 .7 .07],'Lower LFT: z = F_l(P,K) w');
label([.24 .015 .65 .075], ...
    'P_{22} = -G: nessun ulteriore segno meno nel ramo K');
set_scientific_figure_style(f);
paths=fullfile(root,'results','figures','m10_lower_lft_block_diagram.png');
exportgraphics(f,paths,'Resolution',200);
copyfile(paths,fullfile(root,'report','figures','m10_lower_lft_block_diagram.png'));

    function box(position,content)
        % Rettangoli bianchi e testo nero, senza dipendenza dal tema desktop.
        annotation(f,'textbox',position,'String',content,'FitBoxToText','off', ...
            'HorizontalAlignment','center','VerticalAlignment','middle', ...
            'FontSize',14,'Color','black','BackgroundColor','white','LineWidth',1.5);
    end
    function label(position,content)
        annotation(f,'textbox',position,'String',content,'EdgeColor','none', ...
            'HorizontalAlignment','center','FontSize',14,'Color','black');
    end
    function arrow(x,y)
        annotation(f,'arrow',x,y,'Color','black','LineWidth',1.5);
    end
    function lineSegment(x,y)
        annotation(f,'line',x,y,'Color','black','LineWidth',1.5);
    end
end
