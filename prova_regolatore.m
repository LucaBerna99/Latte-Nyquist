clc
clear all
close all

warning('off', 'images:imshow:magnificationMustBeFitForDockedFigure');

%dati
DATI=struct('m', 0.11, 'g',9.81, 'L',1, 'd',0.03, 'R',0.015, 'J',9.99*10^-6);
m_eq= DATI.m+(DATI.J/DATI.R^2);
k=(DATI.m*DATI.g*DATI.d) / (m_eq * DATI.L);

%matrici del sistema
A=[0 1;0 0];
B=[0, k]';
C=[1 0];
D=0;
sist=ss(A, B, C, D);

%Immagini modello Simulink sistema
I1=imread('Ball_Beam.png');
set(figure, 'WindowStyle', 'docked');
imshow(I1);
title('Modello del Sistema Fisico');

clear I1

I2=imread('Simulink.png');
set(figure, 'WindowStyle', 'docked');
imshow(I2);
title('Modello in Anello Aperto');

clear I2

%funzione di trasferimento
G=tf(sist);
set(figure, 'WindowStyle', 'docked');
bode(sist, {0.01, 100});
grid on;

%risposta a scalino
t=0:0.01:10;
[y,t,x]=step(sist, t);
set(figure, 'WindowStyle', 'docked');
plot (t, y);
grid on;
title('Risposta a Scalino');
xlabel('t');
ylabel('y(t)');


%avvio simulazione simulink
SimOut=sim('ball_beam_simulink.slx','ReturnWorkspaceOutputs','on');

%confronto simulazioni
set(figure, 'WindowStyle', 'docked');
plot(t, y, 'linewidth', 2);
hold on
plot (SimOut.tout ,SimOut.yout,'r--', 'linewidth', 2);
grid on;
title('Confronto risposte a scalino');
xlabel('t');
ylabel('y(t)');
legend('Step','Simulink');
set(legend,'Location','bestoutside');

%Scelta posizione di assestamento da parte dell'utente
while true
    PROMPT={'Inserire un valore compreso tra 0 e 1 attorno al quale si vuole assestare la pallina'};
    NAME='POSIZIONE FINALE';
    r_fin_cell=inputdlg(PROMPT, NAME);
    r_fin=str2double(r_fin_cell{1, 1});
    if r_fin>0 && r_fin<1
        break;
    end
end

clear r_fin_cell
clear PROMPT
clear NAME

%Ipotesi pulsazone di partenza per esecuzione del programma
w=10;

%inizializzazione variabili

%Vincoli di progetto
S=0.05;
Ta=3;
cost=0;
num=[1/w, 1];
den=[1/w, 1];
R2=tf(num, den);
L2=series(R2, G);
F=feedback(L2, 1);

u=r_fin*ones(size(t));
ys=lsim(F, u, t);
y_inf=r_fin*ones(size(t));

%Ricerca poli zeri
while true
    
    cost=cost+0.1;
    num=[1/((w)*10^(-cost)), 1];
    den=[1/((w)*10^(cost)), 1];
    R2=tf(num, den);
    
    for mu=1:20
        
        R1=tf(mu, 1);
        R=series(R1, R2);
        L2=series(R, G);
        F=feedback(L2, 1);
        ys=r_fin*step(F, t);
        y_inf=r_fin*ones(size(t));
        Info=lsiminfo(ys, t);
        Ta_reale=Info.SettlingTime;
        S_reale=(Info.Max-r_fin)/r_fin;
        PRESTAZIONI = allmargin(L2);
        if (Ta_reale<Ta && S_reale<S && PRESTAZIONI.PhaseMargin>60)
            break
        end
    end
    if (Ta_reale<Ta && S_reale<S && PRESTAZIONI.PhaseMargin>60)
        break
    end
end

%inizializzazione nuove variabili per Simulink
num_R=cell2mat(R.Numerator);
den_R=cell2mat(R.Denominator);
pole(L2);
zero(L2);

%Immagine Simulink retroazionato
I3=imread('Simulink_retroazionato.png');
set(figure, 'WindowStyle', 'docked');
imshow(I3);
title('Modello Retroazionato');

clear I3

%Risposta a scalino in anello chiuso
set(figure, 'WindowStyle', 'docked');
plot(t, ys, t, y_inf);
axis ([0 10 0 1]);
title('Risposta a Scalino in Anello Chiuso');
xlabel('t');
ylabel('y(t)');
grid on;

%Diagramma di Bode
set(figure, 'WindowStyle', 'docked');
bode(L2, {0.001, 1000});
grid on;

%Diagramma di Nyquist
set(figure, 'WindowStyle', 'docked');
nyquistplot(L2);
xlim ([-10 0]);

%scelta pulsazione da parte dell'utente
PROMPT2={'Inserire il valore della pulsazione del disturbo sinusoidale in ingresso:'};
NAME2='PULSAZIONE DISTURBO';
wd_cell=inputdlg(PROMPT2, NAME2);
wd=str2double(wd_cell{1, 1});

clear wd_cell
clear PROMPT2
clear NAME2
    
%scelta ampiezza massima per stabilità tramite modello simulink
amp=0.1;
while true
    amp = amp+0.1;
    SimOut2 = sim('ball_beam_retroazionato_simulink.slx','ReturnWorkspaceOutputs','on');  %ingresso con disturbo
    ys2=SimOut2.yout;
    if max(ys2)>1 || min(ys2)<0
        amp = amp-0.1;
        SimOut2=sim('ball_beam_retroazionato_simulink.slx','ReturnWorkspaceOutputs','on');
        break
    end
end

%Immagine Simulink retroazionato con disturbo
I4=imread('Simulink_retroazionato_disturbo.png');
set(figure, 'WindowStyle', 'docked');
imshow(I4);
title('Modello Retroazionato');

clear I4

%Risposta a scalino in anello chiuso con disturbo sinusoidale
set(figure, 'WindowStyle', 'docked');
plot (SimOut2.tout ,SimOut2.yout, t, y_inf);
axis ([0 10 -0.2 1.2]);
grid on;
title('Risposta a scalino in anello chiuso con disturbo sinusoidale');
xlabel('t');
ylabel('r(t)');

%Bode Sensitività Complementare
set(figure, 'WindowStyle', 'docked');
bode(feedback(L2, 1), {0.001, 1000});
title('Sensitività complementare F(s)');
grid on;

%message box con commento risultati
uiwait(msgbox('I Risultati sono stati salvati nel file PRESTAZIONI.txt','RISULTATI', 'modal'));

[num_L2, den_L2] = tfdata(L2);
num_L2=cell2mat(num_L2);
den_L2=cell2mat(den_L2);

fp = fopen('PRESTAZIONI.txt', 'w');
fprintf(fp, 'FUNZIONE DI ANELLO:\n\n');
fprintf(fp, 'Numeratore: [%.3f, %.3f, %.3f, %.3f]\n', num_L2);
fprintf(fp, 'Denominatore: [%.3f, %.3f, %.3f, %.3f]\n\n\n\n', den_L2);
fprintf(fp, 'DATI FUNZIONE DI ANELLO:\n\n');
fprintf(fp, 'Guadagno: %.3f\n', k*mu);
fprintf(fp, 'Polo: %.3f\n', pole(L2));
fprintf(fp, 'Zero: %.3f\n\n\n\n', zero(L2));
fprintf(fp, 'PRESTAZIONI RICHIESTE:\n\n');
fprintf(fp, 'Tempo di Assestamento %.3f s\n', Ta);
fprintf(fp, 'Sovraelongazione Percentuale %.3f %%\n\n\n', 100*S);
fprintf(fp, 'PRESTAZIONI IN ANELLO CHIUSO:\n\n');
fprintf(fp, 'Pulsazione di Attraversamento: %.3f rad/s \n', PRESTAZIONI.DMFrequency);
fprintf(fp, 'Margine di Fase: %.3f °\n', PRESTAZIONI.PhaseMargin);
fprintf(fp, 'Tempo di Assestamento %.3f s\n', Ta_reale);
fprintf(fp, 'Sovraelongazione Percentuale %.3f %%\n\n\n', 100*S_reale);
fprintf(fp, 'Ampiezza massima Disturbo Sinusoidale con Pulsazione Data %.3f m\n', amp);
fclose(fp);

clear fp
open('PRESTAZIONI.txt');

clear ans