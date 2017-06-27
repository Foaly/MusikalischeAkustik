[1mdiff --git a/Uebung03/Latex/Aufgabe1.tex b/Uebung03/Latex/Aufgabe1.tex[m
[1mindex 6f32e7e..be30e71 100644[m
[1m--- a/Uebung03/Latex/Aufgabe1.tex[m
[1m+++ b/Uebung03/Latex/Aufgabe1.tex[m
[36m@@ -35,7 +35,7 @@[m [mDerselbe Effekt lässt sich auch mithilfe eines spektralen Features beschreiben.[m
 Beim Spielen lauter Töne wird zudem der Ton schneller aufgebaut, was mit der Geschwindigkeit des Bogens zusammenhängt. Außerdem wird der Bogen bei leise gespielten Tönen langsamer von der Saite weggenommen. Diese beiden Merkmale lassen sich mit den temporalen Deskriptoren \textit{Attack Time} und \textit{Release Time} erfassen. \\[m
 [m
 \subsection{}[m
[31m-Wir gehen davon aus, dass die analysierten Violinen-Samples unter gleichbleibenden Aufnahmebedingungen entstanden sind. [m
[32m+[m[32mWir gehen davon aus, dass die analysierten Violinen-Samples unter gleichbleibenden Aufnahmebedingungen entstanden sind.[m
 Deswegen sollte die Dynamikstufe mit der Leistung verknüpft sein, d.h. lauter Spielen gibt uns mehr Energie pro Zeiteinheit, wenn wir die in Abschnitt a. beschriebenen Schwankungen außer Beracht lassen. Wir verwenden deswegen die \textit{Frame Energy} als leistungsabhängiges Feature. \\[m
 Beim Blick auf die Scatterplots (siehe figures!!) sehen wir allerdings nur beim Deskriptor Harmonic Energy eine deutliche Korrelation mit der Frame Energy. [m
 Dies hätten wir eigentlich auch bei den anderen leistungsunabhängigen Größen erwartet hätten, sofern wir die Frame Energy als direkten Indikator für Dynamik ansehen.[m
[1mdiff --git a/Uebung03/Latex/header.tex b/Uebung03/Latex/header.tex[m
[1mindex b4097eb..da18178 100755[m
[1m--- a/Uebung03/Latex/header.tex[m
[1m+++ b/Uebung03/Latex/header.tex[m
[36m@@ -31,7 +31,7 @@[m
 [m
 \automark{section}[m
 \ohead{\parbox[b]{0.49\textwidth}{\raggedleft\headmark}\vspace*{0.01mm}}[m
[31m-\ofoot*{\pagemark}[m
[32m+[m[32m\ofoot*{\pagemark / \lastpage}[m
 [m
 \usepackage{enumerate}[m
 \usepackage{amsmath}[m
[1mdiff --git a/Uebung03/Latex/main.tex b/Uebung03/Latex/main.tex[m
[1mindex 8a408f0..9070be1 100755[m
[1m--- a/Uebung03/Latex/main.tex[m
[1m+++ b/Uebung03/Latex/main.tex[m
[36m@@ -1,5 +1,6 @@[m
 \input{header.tex}[m
 \ihead{\parbox[b]{0.51\textwidth}{\includegraphics[height=8pt]{akt.png}~\includegraphics[height=8pt]{tu.png} AUDIO FEATURE EXTRACTION}\vspace*{0.01mm}}[m
[32m+[m
 \begin{document}[m
 [m
 %--------------------------------[m
[1mdiff --git a/Uebung03/Python/main.py b/Uebung03/Python/main.py[m
[1mindex 4aea15c..92b35cb 100644[m
[1m--- a/Uebung03/Python/main.py[m
[1m+++ b/Uebung03/Python/main.py[m
[36m@@ -39,24 +39,25 @@[m [mdef main():[m
     plt.scatter(frameErg, harmonicErg)[m
     plt.xlabel("Frame Energy")[m
     plt.ylabel("Harmonic Energy")[m
[31m-    plt.show()[m
[32m+[m[32m    #plt.show()[m
 [m
     plt.scatter(frameErg, rel)[m
     plt.xlabel("Frame Energy")[m
     plt.ylabel("Release Time")[m
[31m-    plt.show()[m
[32m+[m[32m    #plt.show()[m
 [m
     plt.scatter(frameErg, specSkew)[m
     plt.xlabel("Frame Energy")[m
     plt.ylabel("Spectral Skew")[m
[31m-    plt.show()[m
[32m+[m[32m    #plt.show()[m
 [m
     plt.scatter(frameErg, att)[m
     plt.xlabel("Frame Energy")[m
     plt.ylabel("Attack Time")[m
[31m-    plt.show()[m
[32m+[m[32m    #plt.show()[m
 [m
     # Aufgabe 3 d)[m
[32m+[m[32m    KMeans()[m
 [m
 [m
 [m
