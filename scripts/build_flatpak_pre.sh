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

set -e

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)    FLAT_ARCH="x86_64" ;;
  aarch64)   FLAT_ARCH="aarch64" ;;
  arm64)     FLAT_ARCH="aarch64" ;;
  *)         echo "Unsupported arch: ${ARCH}"; exit 1 ;;
esac

apt-get install -y flatpak flatpak-builder

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y "org.freedesktop.Sdk/${FLAT_ARCH}/23.08"
flatpak install -y "org.freedesktop.Platform/${FLAT_ARCH}/23.08"
flatpak install -y flathub org.freedesktop.appstream-glib
