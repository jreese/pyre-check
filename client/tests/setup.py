# Copyright (c) Facebook, Inc. and its affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

import contextlib
import json
import os
from pathlib import Path
from typing import Any, Generator, Iterable, Mapping, Optional

from ..find_directories import CONFIGURATION_FILE, LOCAL_CONFIGURATION_FILE


def ensure_files_exist(root: Path, relatives: Iterable[str]) -> None:
    for relative in relatives:
        full_path = root / relative
        full_path.parent.mkdir(parents=True, exist_ok=True)
        full_path.touch(exist_ok=True)


def ensure_directories_exists(root: Path, relatives: Iterable[str]) -> None:
    for relative in relatives:
        full_path = root / relative
        full_path.mkdir(parents=True, exist_ok=True)


def write_configuration_file(
    root: Path, content: Mapping[str, Any], relative: Optional[str] = None
) -> None:
    if relative is None:
        (root / CONFIGURATION_FILE).write_text(json.dumps(content))
    else:
        local_root = root / relative
        local_root.mkdir(parents=True, exist_ok=True)
        (local_root / LOCAL_CONFIGURATION_FILE).write_text(json.dumps(content))


@contextlib.contextmanager
def switch_working_directory(directory: Path) -> Generator[None, None, None]:
    original_directory = Path(".").resolve()
    try:
        os.chdir(str(directory))
        yield None
    finally:
        os.chdir(str(original_directory))


@contextlib.contextmanager
def switch_environment(environment: Mapping[str, str]) -> Generator[None, None, None]:
    old_environment = dict(os.environ)
    os.environ.clear()
    os.environ.update(environment)
    try:
        yield
    finally:
        os.environ.clear()
        os.environ.update(old_environment)
