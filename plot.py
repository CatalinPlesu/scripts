#!/bin/python
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
import numpy as np
import csv
import os
import math
import sys

color = ['b', 'g', 'r', 'y', 'm', 'c', 'k', 'w']

OUT_DIR = 'png'
PATH = 'csv'

try:
    os.mkdir(OUT_DIR)
except:
    pass

def read_csv_file(filename):
    file = []
    with open(PATH + '/' + filename,'r') as csvfile:
        plots = csv.reader(csvfile, delimiter = ',')
        for row in plots:
            file.append(row)
    return file

def clean_csv_matrix(file):
    max_row_len = len(file[0])
    for i,r in enumerate(file):
        for j,c in enumerate(file[i]):
            if c == '':
                file[i][j] = 0
            try:
                # file[i][j] = round(float(c), 4)
                file[i][j] = float(c)
            except:
                pass

        if len(r) < max_row_len:
            file[i].append(0)
    return file

def transpose_csv_matrix(file):
    zipped_rows = zip(*file)
    return [list(row) for row in zipped_rows]

def print_csv_matrix(matrix):
    for r in matrix:
        print(*r)

def plot_to_png(file, filename):
    x = file[0][1:len(file[0])]
    l_y = []
    yn = []
    y_max = 0
    y_min = 0
    for i, line in enumerate(file[1:len(file)]):
        l_y.append(file[i + 1][0])
        yn.append(file[i + 1][1:len(file[0])])
        if y_max < max(yn[i]):
            y_max = max(yn[i])
        if y_min < min(yn[i]):
            y_min = min(yn[i])

    y_max = math.ceil(y_max)
    y_min = math.floor(y_min)

    # output size
    plt.figure(figsize=(16, 9))

    # OX, OY axes
    plt.axhline(0, color=color[6])
    plt.axvline(0, color=color[6])

    for i, y in enumerate(yn):
        plt.plot(x, y, color = color[i], linestyle = 'solid', marker = 'o',label = l_y[i])

    plt.grid()
    plt.xticks(np.arange(min(x), max(x)+1, 1.0))
    plt.xlabel(file[0][0])
    plt.ylabel(X_LABEL)
    plt.title('Titlu')
    plt.legend()
    plt.savefig(f"{OUT_DIR}/{filename}.png", dpi=100)
    # plt.show()


X_LABEL = 'Axa oy'
if len(sys.argv) >= 2:
    PATH = sys.argv[1]
if len(sys.argv) >= 3:
    X_LABEL = sys.argv[2]

if __name__ == "__main__":
    print("inpute files path =", PATH)
    fileNames = os.listdir(PATH)
    fileNames = [file for file in fileNames if '.csv' in file and '#' not in file]
    for filename in fileNames:
        print(filename, "is being processed")
        file = read_csv_file(filename)
        file = clean_csv_matrix(file)
        # print_csv_matrix(file)

        file = transpose_csv_matrix(file)
        # print_csv_matrix(file)

        plot_to_png(file, filename[0:len(filename)-4])
        print(filename, "SUCCESSFULLY plotted to png in png floder")
