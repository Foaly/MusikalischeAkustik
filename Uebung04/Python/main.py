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

        return result


def main():
    buk04_amplitude = loadFile('../SinusoidsTXT/TwoNote_BuK_04.AMPL')
    print(buk04_amplitude)

if __name__ == '__main__':
    main()
