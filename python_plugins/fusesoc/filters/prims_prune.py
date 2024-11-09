import logging
from functools import cache

logger = logging.getLogger(__name__)


@cache
def library(vlnv: str) -> str:
    return vlnv.split(":")[1]


@cache
def name(vlnv: str) -> str:
    return vlnv.split(":")[2]


@cache
def prim_type(vlnv: str) -> str:
    return library(vlnv).removeprefix("prims_")


def is_prim(vlnv: str) -> bool:
    return library(vlnv).startswith("prims")


def is_abstract_prim(vlnv: str) -> bool:
    return library(vlnv) == "prims"


def is_concrete_prim(vlnv: str) -> bool:
    return library(vlnv).startswith("prims_")


PRIM_PRIORITY: tuple[str, ...] = ("specific", "generic")
# PRIM_PRIORITY: tuple[str, ...] = ("generic", "specific")


class Prims_prune:
    def run(self, edam, _):
        # All concrete primitives
        concrete_prims = [
            core for core in edam["dependencies"] if is_concrete_prim(core)
        ]

        # Sort the concrete primitives in order of priority
        prim_priority = {
            name: priority + 1 for (priority, name) in enumerate(PRIM_PRIORITY)
        }
        concrete_prims.sort(
            key=lambda core: prim_priority.get(prim_type(core), 0)
        )
        for core in concrete_prims:
            if prim_priority.get(prim_type(core)) is None:
                logger.warning(
                    f"{core} has an unknown primitive type: "
                    f"'{prim_type(core)}'"
                )

        # Select the highest priority implementation for every required
        # primitive
        selected_prims: dict[str, str] = {}
        for core in concrete_prims:
            if name(core) not in selected_prims:
                selected_prims[name(core)] = core

        # Check all abstract primitives have concrete implementations
        for core in edam["dependencies"]:
            if is_abstract_prim(core) and name(core) not in selected_prims:
                logger.error(f"{core} doesn't have a concrete implementation.")

        # Pruning helper functions
        def unused_prim(core: str) -> bool:
            return is_prim(core) and core not in selected_prims.values()

        def replace_with_selected_prims(vlnv: str) -> str:
            if unused_prim(vlnv):
                vlnv = selected_prims[name(vlnv)]
            return vlnv

        # Remove unused primitives from the map
        # and convert dependencies to their concrete form.
        edam["dependencies"] = {
            # Replace each primitive with selected concrete type
            core: list(set(map(replace_with_selected_prims, core_deps)))
            for (core, core_deps) in edam["dependencies"].items()
            # Remove unused primitives
            if not unused_prim(core)
        }

        # Remove unused primitives from file list
        edam["files"] = list(
            filter(lambda file: not unused_prim(file["core"]), edam["files"])
        )

        return edam
