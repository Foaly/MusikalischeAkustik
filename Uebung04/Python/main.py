import scipy.io as sio
import numpy as np
import matplotlib.pyplot as plt

import csv


def loadFile(filename):
    with open(filename) as csvfile:
        result = []
        reader = csv.reader(csvfile, delimiter=" ")
        for row in reader:
            if row[-1] == ';':
                del row[-1]
            result.append(row)

        return np.array(result)

def loadRecording(filename):
    amplitudes = loadFile(filename + ".AMPL")
    frequencies = loadFile(filename + ".FREQ")
    f0s = loadFile(filename + ".F0")
    phases = loadFile(filename + ".PHA")
    return amplitudes, frequencies, f0s, phases


def main():

    # a)
    buk04_amplitude, buk04_frequencies, buk04_f0s, buk04_phases = loadRecording('../SinusoidsTXT/TwoNote_BuK_04')
    buk23_amplitude, buk23_frequencies, buk23_f0s, buk23_phases = loadRecording('../SinusoidsTXT/TwoNote_BuK_23')

    # b)
    buk04_amplitude_T = np.transpose(buk04_amplitude)
    buk23_amplitude_T = np.transpose(buk23_amplitude)

    for i in range(5):
        plt.plot(buk04_amplitude_T[i])
    plt.xlabel("Frame")
    plt.ylabel("Amplitude")
    plt.show()

    for i in range(5):
        plt.plot(buk23_amplitude_T[i])
    plt.xlabel("Frame")
    plt.ylabel("Amplitude")
    plt.show()

if __name__ == '__main__':
    main()
