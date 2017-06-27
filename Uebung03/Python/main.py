import scipy.io as sio
import glob
import matplotlib.pyplot as plt

import numpy as np

from sklearn.cluster import KMeans
import scipy.cluster.vq


def main():

    # load mat files
    matfiles = []
    for filename in glob.glob('../Features/*.mat'):
        matfiles.append(sio.loadmat(filename))

    # Aufgabe 3 c)
    frameErg = []
    harmonicErg = []
    rel = []
    specSkew = []
    att = []
    for i in range(len(matfiles)):
        features = matfiles[i]['tempModel']
        frameErg.append(features['STFTpow_FrameErg_median'])
        harmonicErg.append(features['Harmonic_HarmErg_median'])
        rel.append(features['TEE_Rel'])
        specSkew.append(features['STFTpow_SpecSkew_median'])
        att.append(features['TEE_Att'])

        #y.append(features['Harmonic_TriStim3_median'])
        #y.append(features['STFTpow_SpecSlope_median'] * 100)
        #y.append(features['STFTpow_SpecDecr_median'])
        #y.append(features['STFTpow_SpecSpread_median'])
        #y.append(features['TEE_AttSlope'])
        #y.append(features['AS_AutoCorr1_median'])

    plt.scatter(frameErg, harmonicErg)
    plt.xlabel("Frame Energy")
    plt.ylabel("Harmonic Energy")
    #plt.show()

    plt.scatter(frameErg, rel)
    plt.xlabel("Frame Energy")
    plt.ylabel("Release Time")
    #plt.show()

    plt.scatter(frameErg, specSkew)
    plt.xlabel("Frame Energy")
    plt.ylabel("Spectral Skew")
    #plt.show()

    plt.scatter(frameErg, att)
    plt.xlabel("Frame Energy")
    plt.ylabel("Attack Time")
    #plt.show()

    # Aufgabe 3 d)
    KMeans()



if __name__ == '__main__':
    main()