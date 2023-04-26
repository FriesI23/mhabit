# coding: utf-8
# Copyright 2023 Fries_I23
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import math
import numpy as np
import matplotlib.pyplot as plt


def intervalTrans(x, a1, a2, b1, b2):
    return (b2 - b1) * (x - a1) / (a2 - a1) + b1


def growCurve(days=30, x=1, y0=0, y1=100):
    x0 = 0
    k = 0.4
    minx = -10
    maxx = 10

    newx = intervalTrans(x, 0, days, minx, maxx)
    # print(x, 0, days, minx, maxx, newx)

    y = 1 / (1 + math.exp(-k * (newx - x0)))
    return intervalTrans(y, y0, y1, 0, 100)


if __name__ == '__main__':
    days = 66
    x = [i for i in range(0, days + 1)]
    ya = growCurve(x=0, days=days)
    yb = growCurve(x=days, days=days)
    y = [growCurve(x=i, days=days, y0=ya, y1=yb) for i in x]
    print(x)
    print([round(i, 2) for i in y])
    plt.plot(x, y, '-r', label='Logistic Function')
    plt.xlabel('x')
    plt.ylabel('y')
    plt.legend()
    plt.show()
