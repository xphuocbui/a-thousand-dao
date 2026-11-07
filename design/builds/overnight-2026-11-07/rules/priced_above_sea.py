"""Priced Above the Sea. A stone-paid art may have a cost share above 1, and the art lint
applies unchanged. Without this plug-in such an art cannot fire. Needs stone_payment.
"""


def install(f):
    f.stone_share_cap = float("inf")
