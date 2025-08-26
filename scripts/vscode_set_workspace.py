# Copyright 2025 Fries_I23
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import io
import os
import sys
import json
import logging
import copy

from argparse import ArgumentParser

here = os.path.dirname(__file__)


def init_parser():
    """..."""
    parser = ArgumentParser()
    parser.add_argument("-n", "--name", default="mhabit")
    parser.add_argument("-op", "--output-path", default=".")
    parser.add_argument(
        "--code-workspace",
        default=os.path.abspath(
            os.path.join(here, "..", ".templates", "vscode", "code-workspace.default")
        ),
    )
    parser.add_argument(
        "--launchs",
        nargs="+",
        type=str,
        default=[
            os.path.abspath(
                os.path.join(here, "..", ".templates", "vscode", "launch.json.default")
            )
        ],
    )
    parser.add_argument(
        "--settings",
        nargs="+",
        type=str,
        default=[
            os.path.abspath(
                os.path.join(here, "..", ".templates", "vscode", "settings.json.default")
            ),
            os.path.abspath(
                os.path.join(
                    here, "..", ".templates", "vscode", "settings.json.recommend"
                ),
            ),
        ],
    )
    parser.add_argument("--licenser-author", type=str, default=None)
    parser.add_argument("--dart-flutterSdkPath", type=str, default=None)
    parser.add_argument("--x11-display", type=str, default=None)
    parser.add_argument("-f", "--force", action="store_true", default=False)
    parser.add_argument("--dry-run", action="store_true", default=False)
    parser.add_argument("-v", "--verbose", action="store_true", default=False)
    return parser


def main():
    """..."""
    parser = init_parser()
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(level=logging.DEBUG)
    name: str = args.name
    output_path: str = args.output_path
    code_workspace_path: str = args.code_workspace
    launch_paths: list[str] = args.launchs
    setting_paths: list[str] = args.settings
    setting_opts: dict[str:any] = {
        "licenser.author": args.licenser_author,  # type: str | None
        "dart.flutterSdkPath": args.dart_flutterSdkPath,  # type: str | None
    }
    launch_envs: dict[str:any] = {}
    if args.x11_display is not None:
        launch_envs["DISPLAY"] = args.x11_display
    output = process(
        name=name,
        output_path=output_path,
        code_workspace_path=code_workspace_path,
        code_launch_paths=launch_paths,
        code_setting_paths=setting_paths,
        force=args.force,
        dry_run=args.dry_run,
        setting_opts=setting_opts,
        launch_envs=launch_envs,
    )
    if output:
        print(output)


def check_path_exist(path: str) -> tuple[int, str | None]:
    """..."""
    if not os.path.exists(path):
        return 1, f"path not found: {path}"
    return 0, None


def merge_json(a: any, b: any) -> any:
    """..."""
    if isinstance(a, dict) and isinstance(b, dict):
        result = a.copy()
        for key, value in b.items():
            if key in result:
                result[key] = merge_json(result[key], value)
            else:
                result[key] = value
        return result
    elif isinstance(a, list) and isinstance(b, list):
        return a + b
    else:
        return b


def merge_settings(settings: list[dict[str, any]]) -> dict[str, any]:
    """..."""
    settings_count = len(settings)
    if settings_count <= 0:
        return {}
    if settings_count == 1:
        return copy.deepcopy(settings[0])

    setting = copy.deepcopy(settings[0])
    for ow_setting in settings[1:]:
        setting = merge_json(setting, ow_setting)
    return setting


def merge_launchs(launchs: list[dict[str, any]]) -> dict[str, any]:
    """..."""
    launchs_count = len(launchs)
    if launchs_count <= 0:
        return {}
    if launchs_count == 1:
        return copy.deepcopy(launchs[0])

    conf_key = "configurations"
    config = copy.deepcopy(launchs[0]).get(conf_key, [])
    for ow_launch in launchs[1:]:
        launch_configs = {cfg["name"]: cfg for cfg in config if "name" in cfg}
        ow_config = ow_launch.get(conf_key, [])
        ow_launch_configs = {cfg["name"]: cfg for cfg in ow_config if "name" in cfg}
        launch_configs.update(ow_launch_configs)
        if launch_configs:
            config = list(launch_configs.values())

    launch = copy.deepcopy(launchs[0])
    for ow_config in launchs[1:]:
        launch = merge_json(launch, ow_config)
    if config:
        ow_config[conf_key] = config
    return launch


def process(
    name: str,
    output_path: str,
    code_workspace_path: str,
    code_launch_paths: list[str],
    code_setting_paths: list[str],
    force: bool,
    dry_run: bool,
    setting_opts: dict[str:any] = None,
    launch_envs: dict[str:any] = None,
) -> str | None:
    """..."""
    setting_opts = setting_opts or {}
    launch_envs = launch_envs or {}

    def check_path(path):
        rst, errmsg = check_path_exist(path)
        if errmsg:
            logging.error(errmsg)
            sys.exit(rst)

    check_path(code_workspace_path)
    for path in code_launch_paths:
        check_path(path)
    for path in code_setting_paths:
        check_path(path)

    if os.path.isfile(output_path):
        output_filepath = output_path
    else:
        output_filepath = os.path.join(output_path, f"{name}.code-workspace")

    with open(code_workspace_path, "r", encoding="utf-8") as fp:
        workspace_data: dict[str, any] = json.load(fp)
        del workspace_data["$schema"]

    raw_launch_datas = []
    for path in code_launch_paths:
        with open(path, "r", encoding="utf-8") as fp:
            raw_launch_datas.append(json.load(fp))
    launch_data = merge_launchs(raw_launch_datas)

    raw_setting_datas = []
    for path in code_setting_paths:
        with open(path, "r", encoding="utf-8") as fp:
            raw_setting_datas.append(json.load(fp))
    setting_data = merge_settings(raw_setting_datas)

    ws_data = merge_settings((workspace_data.get("settings", {}), setting_data))
    del ws_data["$schema"]
    if ws_data:
        workspace_data["settings"] = ws_data

    wl_data = merge_launchs((workspace_data.get("launch", {}), launch_data))
    del wl_data["$schema"]
    if wl_data:
        workspace_data["launch"] = wl_data

    logging.info("code-workspace: %s", code_workspace_path)
    logging.info("launch.json: %s", code_launch_paths)
    logging.info("settings.json: %s", code_setting_paths)
    logging.info("output path: %s", output_filepath)
    logging.info("settings -opts: %s", setting_opts)
    logging.info("launch -envs: %s", launch_envs)
    logging.info("force: %s", force)
    logging.info("dry-run: %s", dry_run)

    if setting_opts.get("licenser.author"):
        workspace_data.setdefault("settings", {})["licenser.author"] = setting_opts[
            "licenser.author"
        ]
    if setting_opts.get("dart.flutterSdkPath"):
        sdk_path = setting_opts["dart.flutterSdkPath"]
        settings: dict[str, any] = workspace_data.setdefault("settings", {})
        settings["dart.flutterSdkPath"] = sdk_path
        sdk_paths = settings.get("dart.flutterSdkPaths", [])
        if sdk_path not in sdk_paths:
            settings.setdefault("dart.flutterSdkPaths", []).append(sdk_path)
        al_folders = settings.get("dart.analysisExcludedFolders", [])
        if sdk_path not in al_folders:
            settings.setdefault("dart.analysisExcludedFolders", []).append(sdk_path)

    if launch_envs:
        for conf in workspace_data.get("launch", {}).get("configurations", []):
            conf: dict[str, any]
            base_env = conf.get("env", {})
            env = merge_json(base_env, launch_envs)
            if env:
                conf["env"] = env

    workspace_json = json.dumps(workspace_data, indent=2)
    bf = io.StringIO()
    print("// THIS FILE IS GENERATE FROM TEMPLATES:", file=bf)
    print("// - code-workspace:", file=bf)
    print(f"//   - {code_workspace_path}", file=bf)
    print("// - settings.json:", file=bf)
    for i in [f"//   - {i}" for i in code_setting_paths]:
        print(i, file=bf)
    print("// - launch.json:", file=bf)
    for i in [f"//   - {i}" for i in code_launch_paths]:
        print(i, file=bf)
    print("//", file=bf)
    print(workspace_json, file=bf)

    if dry_run:
        return bf.getvalue()

    if os.path.exists(output_filepath) and not force:
        logging.error("output file exist: %s", output_filepath)
        sys.exit(1)
    with open(output_filepath, "w", encoding="utf-8") as fp:
        fp.write(bf.getvalue())


if __name__ == "__main__":
    main()
