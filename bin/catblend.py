#/usr/bin/env python

import json
import pprint
import types

import bpy
import idprop
import mathutils
import numpy as np

invisible_types = (
    type(abs), # builtin_function_or_method
    bpy.types.bpy_func,
)

non_data_fields = (
    'bl_rna',
    'rna_type',
)

def is_data_field(field):
    return not field.startswith('__') and \
        not field.endswith('__') and \
        field not in non_data_fields

def encode_identity(obj, visited):
    return obj

def encode_collection(obj, visited):
    if len(obj) > 300:
        return str(obj)
    else:
        return map(lambda obj: encode(obj, visited), list(obj))

def encode_from_dir(obj, visited):
    fields = dir(obj)
    d = {}
    for field in fields:
        if is_data_field(field):
            val = getattr(obj, field)
            if not isinstance(val, invisible_types) and val is not obj:
                d[field] = encode(val, visited, field)
    return d

def encode_from_items(obj, visited):
    d = {}
    for key, val in obj.items():
        if not isinstance(val, invisible_types) and val is not obj:
            d[key] = encode(val, visited, key)
    return d

def encode_struct(obj, visited):
    d = encode_from_dir(obj, visited)
    if (isinstance(obj, (bpy.types.ID, bpy.types.Bone, bpy.types.PoseBone))):
        d.update(encode_from_items(obj, visited))
    return d

def encode_prop_collection(obj, visited):
    d = encode_from_dir(obj, visited)
    d.update(encode_from_items(obj, visited))
    return d

def encode_prop_array(obj, visited):
    return encode_collection(obj, visited)

encoders = {
    (type(None), int, float, str, types.MethodType, range): encode_identity,
    (list, tuple, set): encode_collection,

    bpy.types.bpy_struct: encode_struct,
    bpy.types.bpy_prop_collection: encode_prop_collection,
    bpy.types.bpy_prop_array: encode_prop_array,
    idprop.types.IDPropertyGroup: lambda obj, visited: obj.to_dict(),

    (mathutils.Color, mathutils.Euler, mathutils.Matrix, mathutils.Quaternion, mathutils.Vector): lambda obj, visited: str(obj),
}

def get_encoder(obj):
    for encoder_type, encoder in encoders.items():
        if isinstance(obj, encoder_type):
            return encoder
    raise Exception(f'Type {type(obj)} does not have an associated encoder.')

def obj_id(obj):
    if isinstance(obj, bpy.types.bpy_struct):
        return str(obj.as_pointer()) + str(type(obj))
    else:
        return id(obj)

def was_visited(obj, visited):
    for visited_id, visited_obj, field_name in visited:
        if visited_id == obj_id(obj):
            return True
    return False

def encode(obj, visited, field_name=None):
    if was_visited(obj, visited):
        return None
        #  raise Exception(f'Circular reference for {field_name}: {repr(obj)} ({obj_id(obj)}):\n{pprint.pformat(visited)}')

    return get_encoder(obj)(obj, visited + [(obj_id(obj), obj, field_name)])

encoded = encode(bpy.data, [])
print(json.dumps(encoded))
