from sklearn.preprocessing import normalize
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal


from scipy.io.wavfile import write
import csv
import math
import sys


def loadFile(filename):
    with open(filename) as csvfile:
        result = []
        reader = csv.reader(csvfile, delimiter=" ")
        for row in reader:
            # delete the trailing ';' in the csv files
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


def linearInterpolation(start, end, amount):
    amount = max(min(amount, 1.0), 0.0)  # clamp to range [0, 1]
    return (end * amount) + (start  * (1.0 - amount))


def convertToIntArray(floatSamples):
    ii16 = np.iinfo(np.int16)
    output = np.array(floatSamples) * ii16.max
    return output.astype(np.int16)


def synthesize(amplitudeArray: np.array, f0Array: np.array, fs: int):
    output = []
    frameSize = 128
    numPartials = len(amplitudeArray[0])

    oldAmplitudes = np.zeros(numPartials)
    oldw = 0.0
    omega = np.zeros(numPartials)
    phi = np.zeros(numPartials)

    # iterate over all Stützstellen
    for k in range(len(amplitudeArray)):
        f0         = float(f0Array[k][0])
        w          = 2.0 * math.pi * f0 / fs
        amplitudes = np.array(amplitudeArray[k])
        amplitudes = amplitudes.astype(np.float)

        # iterate over the length of a frame
        for n in range(frameSize):
            sample = 0

            # interpolation
            amount = n / (frameSize - 1)
            interpolatedAmp = linearInterpolation(oldAmplitudes, amplitudes, amount)
            interpolatedw   = linearInterpolation(oldw, w, amount)

            # iterate over all partial tones
            for i in range(numPartials):
                omega[i] = (i + 1) * interpolatedw * (n + 1) + phi[i]
                sample += interpolatedAmp[i] * math.sin(omega[i])

            output.append(sample)

        # save the input to the sin from the frames last iteration as the phase offset for the next frame
        phi = omega.copy()
        oldAmplitudes = amplitudes
        oldw = w

    # normalize to range [0, 1]
    maximum = max(output)
    output = [float(i) / maximum for i in output]

    #plt.figure()
    #plt.plot(output)
    #plt.show()

    return output


def synthesizeWithOvertones(amplitudeArray: np.array, freqArray: np.array, fs: int):
    output = []
    frameSize = 128
    numPartials = len(freqArray[0])

    oldAmplitudes = np.zeros(numPartials)
    oldw = np.zeros(numPartials)
    omega = np.zeros(numPartials)
    phi = np.zeros(numPartials)

    # iterate over all Stützstellen
    for k in range(len(amplitudeArray)):
        frequencies = np.array(freqArray[k])
        frequencies = frequencies.astype(np.float)
        w           = 2.0 * math.pi * frequencies / fs
        amplitudes  = np.array(amplitudeArray[k])
        amplitudes  = amplitudes.astype(np.float)

        # iterate over the length of a frame
        for n in range(frameSize):
            sample = 0

            # interpolation
            amount = n / (frameSize - 1)
            interpolatedAmp = linearInterpolation(oldAmplitudes, amplitudes, amount)
            interpolatedw   = linearInterpolation(oldw, w, amount)

            # iterate over all partial tones
            for i in range(numPartials):
                omega[i] = interpolatedw[i] * (n + 1) + phi[i]
                sample  += interpolatedAmp[i] * math.sin(omega[i])

            output.append(sample)

        # save the input to the sin from the frames last iteration as the phase offset for the next frame
        phi = omega.copy()
        oldAmplitudes = amplitudes
        oldw = w

    # normalize to range [0, 1]
    maximum = max(output)
    output = [float(i) / maximum for i in output]

    plt.figure()
    plt.plot(output)
    plt.show()

    return output


def main():

    # 1a)
    buk04_amplitude, buk04_frequencies, buk04_f0s, buk04_phases = loadRecording('../SinusoidsTXT/TwoNote_BuK_04')
    buk23_amplitude, buk23_frequencies, buk23_f0s, buk23_phases = loadRecording('../SinusoidsTXT/TwoNote_BuK_23')


    # # 1b)
    # buk04_amplitude_T = np.transpose(buk04_amplitude)
    # buk23_amplitude_T = np.transpose(buk23_amplitude)
    #
    # for i in range(5):
    #     plt.plot(buk04_amplitude_T[i], label=str(i+1))
    # plt.legend(loc=2)
    # plt.xlabel("Frame")
    # plt.ylabel("Amplitude")
    # # plt.savefig('../Latex/Figures/buk04_amp.pgf')
    # plt.show()
    #
    # for i in range(5):
    #     plt.plot(buk23_amplitude_T[i], label=str(i+1))
    # plt.legend()
    # plt.xlabel("Frame")
    # plt.ylabel("Amplitude")
    # # plt.savefig('../Latex/Figures/buk23_amp.pgf')
    # plt.show()
    #
    #
    # # 1c)
    # buk04_frequencies_T = np.transpose(buk04_frequencies)
    # buk23_frequencies_T = np.transpose(buk23_frequencies)
    #
    # for i in range(5):
    #     plt.plot(buk04_frequencies_T[i], label=str(i+1))
    # plt.legend()
    # plt.xlabel("Frame")
    # plt.ylabel("Frequenz [Hz]")
    # plt.savefig('../Latex/Figures/buk04_freq.pgf')
    # plt.show()
    #
    # for i in range(5):
    #     plt.plot(buk23_frequencies_T[i], label=str(i+1))
    # plt.legend()
    # plt.xlabel("Frame")
    # plt.ylabel("Frequenz [Hz]")
    # plt.savefig('../Latex/Figures/buk23_freq.pgf')
    # plt.show()

    ##############################
    # 2a)
    ##############################
    #
    fs = 44100
    output_buk04 = synthesize(buk04_amplitude, buk04_f0s, fs)
    write('buk04.wav', fs, convertToIntArray(output_buk04))

    output_buk23 = synthesize(buk23_amplitude, buk23_f0s, fs)
    write('buk23.wav', fs, convertToIntArray(output_buk23))

    # 2b)
    frame = 1024
    overlap = frame // 2

    output_buk04 = np.array(output_buk04)

    # work around for the fucking bug in matplotlib
    output_buk04[output_buk04 == 0.0] = 0.001

    plt.specgram(output_buk04, Fs=fs, NFFT=frame, noverlap=overlap, mode='magnitude')
    plt.ylabel('Frequenz [Hz]')
    plt.xlabel('Zeit [sec]')
    plt.savefig('../Latex/Figures/buk04_spectrogram.pdf')
    plt.show()

    plt.figure()
    output_buk23 = np.array(output_buk23)

    # work around for the fucking bug in matplotlib
    output_buk23[output_buk23 == 0.0] = 0.001

    plt.specgram(output_buk23, Fs=fs, NFFT=frame, noverlap=overlap, mode='magnitude')
    plt.ylabel('Frequenz [Hz]')
    plt.xlabel('Zeit [sec]')
    plt.savefig('../Latex/Figures/buk23_spectrogram.pdf')
    plt.show()

    #############################
    # 3a)
    #############################

    output = synthesizeWithOvertones(buk04_amplitude, buk04_frequencies, fs)
    write('buk04_overtones.wav', fs, convertToIntArray(output))

    output = synthesizeWithOvertones(buk23_amplitude, buk23_frequencies, fs)
    write('buk23_overtones.wav', fs, convertToIntArray(output))

if __name__ == '__main__':
    main()
