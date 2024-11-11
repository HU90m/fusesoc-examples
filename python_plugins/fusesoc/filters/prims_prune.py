import logging
from functools import cache

logger = logging.getLogger(__name__)


FALLBACK_PRIM_TYPE: str = "generic"


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


def is_fallback_prim(vlnv: str) -> bool:
    return prim_type(vlnv) == FALLBACK_PRIM_TYPE


class Prims_prune:
    def run(self, edam, _):
        # All concrete primitives
        concrete_prims: list[str] = [
            core for core in edam["dependencies"] if is_concrete_prim(core)
        ]
        concrete_prims_non_fallback = [
            core for core in concrete_prims if not is_fallback_prim(core)
        ]

        # A map of primitive names to non-fallback implementations.
        # Errors if there are multiple non-fallback implementations.
        concrete_prims_non_fallback_map: dict[str, str] = {}
        for core in concrete_prims_non_fallback:
            if name(core) in concrete_prims_non_fallback_map:
                logger.error(
                    f"There are multiple non-{FALLBACK_PRIM_TYPE} "
                    f"implementations of the {name(core)} given: {core} "
                    f"and {concrete_prims_non_fallback_map[name(core)]}."
                )
                exit(1)
            else:
                concrete_prims_non_fallback_map[name(core)] = core

        # A map of primitive names to fallback implementations.
        concrete_prims_fallback_map = {
            name(core): core
            for core in concrete_prims
            if is_fallback_prim(core)
        }

        # Complete concrete primitives map,
        # prefering the non-fallback implementation.
        concrete_prims_map = (
            concrete_prims_fallback_map | concrete_prims_non_fallback_map
        )

        # Check all abstract primitives.
        for core in edam["dependencies"]:
            if not is_abstract_prim(core):
                continue
            if name(core) not in concrete_prims_map:
                logger.error(f"There is no implementation of {core}.")
                exit(1)

        # Pruning helper functions
        def unused_prim(core: str) -> bool:
            return is_prim(core) and core not in concrete_prims_map.values()

        def replace_with_selected_prims(vlnv: str) -> str:
            if unused_prim(vlnv):
                replacement = concrete_prims_map[name(vlnv)]
                logger.info(f"Replacing {vlnv} with {replacement}.")
                return replacement
            return vlnv

        # Remove unused primitives from the map
        # and convert dependencies to their concrete form.
        edam["dependencies"] = {
            # Replace each primitive with selected concrete type.
            # Intermediate set ensures there are no duplicates.
            core: list(set(map(replace_with_selected_prims, core_deps)))
            for (core, core_deps) in edam["dependencies"].items()
            # Remove unused primitives.
            if not unused_prim(core)
        }

        # Remove unused primitives from file list
        edam["files"] = list(
            filter(lambda file: not unused_prim(file["core"]), edam["files"])
        )

        return edam
