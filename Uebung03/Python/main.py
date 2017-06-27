import scipy.io as sio
import glob
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import itertools

import numpy as np

from sklearn.cluster import KMeans
import scipy.cluster.vq


def main():

    # load mat files
    matfiles = []
    for filename in glob.glob('../Features/*.mat'):
        matfiles.append(sio.loadmat(filename))

    # prepare data
    files = len(matfiles)
    filenames = []
    frameErg = []
    harmonicErg = []
    rel = []
    specSkew = []
    att = []

    featureA = np.zeros((files, 2))
    featureB = np.zeros((files, 2))
    featureC = np.zeros((files, 2))
    featureD = np.zeros((files, 2))

    for i in range(files):
        filenames.append(matfiles[i]['filename'])
        features = matfiles[i]['tempModel']

        frameErgValue = features['STFTpow_FrameErg_median']
        harmonicErgValue = features['Harmonic_HarmErg_median']
        relValue = features['TEE_Rel']
        specSkewValue = features['STFTpow_SpecSkew_median']
        attValue = features['TEE_Att']

        frameErg.append(frameErgValue)
        harmonicErg.append(harmonicErgValue)
        rel.append(relValue)
        specSkew.append(specSkewValue)
        att.append(attValue)

        featureA[i] = [frameErgValue, harmonicErgValue]
        featureB[i] = [frameErgValue, relValue]
        featureC[i] = [frameErgValue, specSkewValue]
        featureD[i] = [frameErgValue, attValue]


    # Aufgabe 3 c)
    plt.scatter(frameErg, harmonicErg)
    plt.xlabel("Frame Energy")
    plt.ylabel("Harmonic Energy")
    plt.show()

    plt.scatter(frameErg, rel)
    plt.xlabel("Frame Energy")
    plt.ylabel("Release Time")
    plt.show()

    plt.scatter(frameErg, specSkew)
    plt.xlabel("Frame Energy")
    plt.ylabel("Spectral Skew")
    plt.show()

    plt.scatter(frameErg, att)
    plt.xlabel("Frame Energy")
    plt.ylabel("Attack Time")
    plt.show()

    # Aufgabe 3 d)
    LABEL_COLOR_MAP = {0: 'b', 1: 'r'}

    fAkm = KMeans(n_clusters=2).fit(featureA)
    plt.scatter(frameErg, harmonicErg, c=[LABEL_COLOR_MAP[l] for l in fAkm.labels_])
    plt.xlabel("Frame Energy")
    plt.ylabel("Harmonic Energy")
    plt.show()

    fDkm = KMeans(n_clusters=2).fit(featureD)
    plt.scatter(frameErg, att, c=[LABEL_COLOR_MAP[l] for l in fDkm.labels_])
    plt.xlabel("Frame Energy")
    plt.ylabel("Attack Time")
    plt.show()

    fBkm = KMeans(n_clusters=2).fit(featureB)
    plt.scatter(frameErg, rel, c=[LABEL_COLOR_MAP[l] for l in fBkm.labels_])
    plt.xlabel("Frame Energy")
    plt.ylabel("Release Time")
    plt.show()

    fCkm = KMeans(n_clusters=2).fit(featureC)
    plt.scatter(frameErg, specSkew, c=[LABEL_COLOR_MAP[l] for l in fCkm.labels_])
    plt.xlabel("Frame Energy")
    plt.ylabel("Spectral Skew")
    plt.show()


    # Aufgabe 3 e)
    fAkm = KMeans(n_clusters=2).fit(featureA)
    label_color = [LABEL_COLOR_MAP[l] for l in fAkm.labels_]
    plt.scatter(frameErg, harmonicErg, c=label_color)
    pp = mpatches.Patch(color=LABEL_COLOR_MAP[0], label='pp')
    ff = mpatches.Patch(color=LABEL_COLOR_MAP[1], label='ff')
    plt.legend(handles=[pp, ff])

    plt.xlabel("Frame Energy")
    plt.ylabel("Harmonic Energy")
    plt.show()

    # export table for latex
    # for name, label in itertools.zip_longest(filenames, fAkm.labels_):
    #     klass = ""
    #     if label == 1:
    #         klass = "pp"
    #     else:
    #         klass = "ff"
    #
    #     print(str(name)[14:-14] + " & " + klass + " \\")



if __name__ == '__main__':
    main()
