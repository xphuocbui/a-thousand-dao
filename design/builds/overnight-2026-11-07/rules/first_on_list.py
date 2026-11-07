"""First on the List (Bảng Thủ), keystone of the Way of the Examination (daos/examination.md).

Asked for with "first_on_list": {"comprehension": 100}. Your L1 is 2 points per point of
comprehension ("per_point" tests another slope), and nothing else, on every channel. Combat's soft start and cap_1 still apply,
because they sit in layer_values. --without first_on_list gives the file's own L1.
"""


def install(f):
    layer_points = f.layer_points

    def points(att, dfn, t, extra, channel):
        x = layer_points(att, dfn, t, extra, channel)
        spec = att.spec.get("first_on_list")
        if spec:
            x[0] = spec.get("per_point", 2) * spec.get("comprehension", 0)
        return x

    f.layer_points = points
