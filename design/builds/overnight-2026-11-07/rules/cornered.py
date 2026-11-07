"""Cornered (Khốn Đấu): a guard, true while your health share is below the enemy's.

Used as {"cornered": true} in a guard. It compares shares of maximum health, read at the moment
of the hit, so it is false at the start of an even fight, and it can flip back. A side under
Stands Over You has an owner on the ground and always counts as cornered.
"""


def install(f):
    original = f.guard_true

    def guard_true(g, own, enemy, t):
        if g and g.get("cornered"):
            if own.__dict__.get("standing"):
                return True
            return max(own.health, 0) / own.health_max < max(enemy.health, 0) / enemy.health_max - 1e-9
        return original(g, own, enemy, t)

    f.guard_true = guard_true
