#!/usr/bin/env python3
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

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

import argparse
import json
import math
import os

RT_FONT_SIZE = 12
LT_FONT_SIZE = 16


class L10nData:
    PRT_EMPTY = 0
    PRT_ALL = 100

    def __init__(self, locale_name, path='', file_suffix='arb'):
        self._locale_name = locale_name
        self._suffix = file_suffix
        self._path = path
        self._data = None

    @property
    def inited(self):
        return self._data is not None

    @property
    def file_path(self):
        return os.path.join(self._path, '.'.join(
            (self._locale_name, self._suffix)))

    @property
    def data(self):
        return self._data

    def get_file_contenet(self):
        if os.path.exists(self.file_path):
            with open(self.file_path, 'r') as fp:
                self._data = json.load(fp)
        else:
            raise Exception(f"Loaded content error from {self.file_path}")

    def compare_with(self, other_data):
        # if not other_data.data:
        #     return L10nData.PRT_ALL
        # if not self.data:
        #     return L10nData.PRT_EMPTY
        org_count, check_count = 0, 0
        for trans_key in other_data.data.keys():
            if trans_key.startswith('@'):
                continue
            org_count += 1
            if trans_key in self.data:
                check_count += 1
        if not org_count:
            return L10nData.PRT_ALL
        return max(
            L10nData.PRT_EMPTY,
            min(L10nData.PRT_ALL, round(check_count / org_count * 100, 2)),
        )


class L10nColor:

    def get_color_by_prt(prt: float):
        if 0 <= prt < 20:
            bg_color = '#FF0000'  # RED
        elif 20 <= prt < 40:
            bg_color = '#FF3300'
        elif 40 <= prt < 60:
            bg_color = '#FF6600'
        elif 60 <= prt < 80:
            bg_color = '#FF9900'
        else:
            bg_color = '#00CC00'  # GREEN

        r, g, b = tuple(int(bg_color[i:i + 2], 16) / 255.0 for i in (1, 3, 5))
        v = max(r, g, b)

        if v < 0.5:
            text_color = 'white'
        else:
            text_color = 'black'

        return bg_color, text_color


class L10nManager:

    def __init__(self, load_dir_path='', source_locale='en'):
        self._load_dir_path = load_dir_path
        self._source_locale = source_locale
        self._locales = {}

    def load_data(self):
        for filename in os.listdir(self._load_dir_path):
            if not os.path.isfile(os.path.join(self._load_dir_path, filename)):
                continue
            base, ext = os.path.splitext(os.path.basename(filename))
            if ext != '.arb':
                continue
            self._locales[base] = L10nData(base, path=self._load_dir_path)

        if self._source_locale not in self._locales:
            raise TypeError(f"Sourge locale {self._source_locale} not found, "
                            f"loaded: {self._locales.keys()}")

        for v in self._locales.values():
            v.get_file_contenet()

    def get_statistics_data(self):
        source_local = self._locales[self._source_locale]
        result = {}
        for name, data in self._locales.items():
            result[name] = data.compare_with(source_local)
        return result

    def get_statistics_graph_demo(self, bar_width=0.5, count=10):
        import random
        data = {'en': 100}
        for i in range(count):
            data[str(i)] = random.randint(L10nData.PRT_EMPTY, L10nData.PRT_ALL)
        return self._get_statistics_graph(stat_data=data, bar_width=bar_width)

    def get_statistics_graph(self, bar_width=0.5):
        data = self.get_statistics_data()
        return self._get_statistics_graph(stat_data=data, bar_width=bar_width)

    def _get_statistics_graph(self, stat_data, bar_width):
        _cats, _vals = [], []
        for k, v in stat_data.items():
            if k == self._source_locale:
                continue
            _cats.append(k)
            _vals.append(v)
        _cats.append(self._source_locale)
        _vals.append(stat_data[self._source_locale])

        colors = plt.cm.viridis(np.linspace(0, 1, len(_cats)))

        fig, ax = plt.subplots(figsize=(10, len(_vals)))

        # ax.barh(_cats, _vals, color=colors, height=bar_width)
        for i, cat in enumerate(_cats):
            ax.barh(cat,
                    _vals[i],
                    color=colors[i],
                    label=cat,
                    height=bar_width)
            latval = min(L10nData.PRT_ALL,
                         max(L10nData.PRT_EMPTY, L10nData.PRT_ALL - _vals[i]))
            ax.barh(cat,
                    latval,
                    color='white',
                    height=bar_width,
                    left=_vals[i])

        ax.set_aspect('auto')
        ax.spines['top'].set_visible(False)
        ax.spines['bottom'].set_visible(False)
        ax.spines['right'].set_visible(False)
        ax.spines['left'].set_visible(False)
        ax.set_xticks([])
        ax.tick_params(axis='y', colors='#808080', labelsize=LT_FONT_SIZE)

        for i, val in enumerate(_vals):
            fill_color, font_color = L10nColor.get_color_by_prt(val)
            plt.text(val + 1.5,
                     i,
                     f'{val}%',
                     va='center',
                     fontsize=RT_FONT_SIZE,
                     color=font_color,
                     bbox=dict(facecolor=fill_color,
                               edgecolor=fill_color,
                               boxstyle='round,pad=0.3'))

        return fig, ax


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--load-path", required=True)
    parser.add_argument("-l", "--locale", default='en', required=False)
    parser.add_argument("--img-outpath",
                        default='./l10n_stat.png',
                        required=False)
    parser.add_argument("--img-show", action='store_true', default=False)
    parser.add_argument("--demo", default=-1, type=int)
    return parser


def main():
    parser = parse_args()
    args = parser.parse_args()
    manager = L10nManager(args.load_path, args.locale)
    if args.demo < 0:
        manager.load_data()
    plt.rcParams['svg.fonttype'] = 'none'
    plt.rcParams['text.usetex'] = False
    plt.rcParams['font.family'] = 'sans-serif'
    fig, ax = manager.get_statistics_graph_demo(
        count=args.demo) if args.demo >= 0 else manager.get_statistics_graph()
    plt.autoscale()
    if args.img_show:
        plt.show()
    else:
        fig.savefig(
            args.img_outpath,
            bbox_inches='tight',
            transparent=True,
        )


if __name__ == "__main__":
    main()
