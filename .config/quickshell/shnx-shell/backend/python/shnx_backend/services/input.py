from __future__ import annotations

from shnx_backend.system import hyprland


VALID_ACCEL_PROFILES = {
    "",
    "adaptive",
    "flat",
    "custom",
}


def _float_option(data: dict, default: float = 0.0) -> float:
    value = data.get("float", default)

    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _string_option(data: dict, default: str = "") -> str:
    value = data.get("str", default)

    if value is None:
        return default

    value = str(value).strip()

    # Hyprland uses this sentinel for an unset/empty string option.
    if not value or value == "[[EMPTY]]":
        return default

    return value


def _int_option(data: dict, default: int = 0) -> int:
    value = data.get("int", default)

    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def get_mouse_settings() -> dict:
    sensitivity = hyprland.get_option(
        "input.sensitivity"
    )

    accel_profile = hyprland.get_option(
        "input.accel_profile"
    )

    follow_mouse = hyprland.get_option(
        "input.follow_mouse"
    )

    return {
        "sensitivity": round(
            _float_option(sensitivity),
            3,
        ),
        "accelProfile": _string_option(
            accel_profile,
            "adaptive",
        ),
        "followMouse": _int_option(
            follow_mouse,
            1,
        ),
    }


def set_sensitivity(value: float) -> dict:
    value = float(value)
    value = max(-1.0, min(1.0, value))

    hyprland.set_input(
        sensitivity=round(value, 3),
    )

    return {
        "success": True,
        "sensitivity": value,
    }


def set_accel_profile(profile: str) -> dict:
    profile = str(profile).strip().lower()

    if profile not in VALID_ACCEL_PROFILES:
        raise ValueError(
            "Invalid acceleration profile: "
            f"{profile!r}"
        )

    hyprland.set_input(
        accel_profile=profile,
    )

    return {
        "success": True,
        "accelProfile": profile,
    }


def set_mouse(
    *,
    sensitivity: float | None = None,
    accel_profile: str | None = None,
) -> dict:
    if (
        sensitivity is None
        and accel_profile is None
    ):
        raise ValueError(
            "No mouse settings were provided"
        )

    normalized_sensitivity = None

    if sensitivity is not None:
        normalized_sensitivity = max(
            -1.0,
            min(1.0, float(sensitivity)),
        )

    normalized_profile = None

    if accel_profile is not None:
        normalized_profile = (
            str(accel_profile)
            .strip()
            .lower()
        )

        if normalized_profile not in VALID_ACCEL_PROFILES:
            raise ValueError(
                "Invalid acceleration profile: "
                f"{normalized_profile!r}"
            )

    hyprland.set_input(
        sensitivity=normalized_sensitivity,
        accel_profile=normalized_profile,
    )

    return {
        "success": True,
        "sensitivity": normalized_sensitivity,
        "accelProfile": normalized_profile,
    }
