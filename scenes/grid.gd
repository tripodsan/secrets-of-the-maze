@tool
extends Polygon2D

@export var grid_size:int = 32:
  set(value):
    grid_size = value
    generate_mesh()

var meshInstance: MeshInstance2D

func _ready():
  generate_mesh()

func generate_mesh():
  meshInstance = get_node_or_null('mesh')
  if !meshInstance: return
  var surface_array = []
  surface_array.resize(Mesh.ARRAY_MAX)

  # PackedVector**Arrays for mesh construction.
  var verts = PackedVector2Array()
  var uvs = PackedVector2Array()
  #var normals = PackedVector3Array()
  var indices = PackedInt32Array()

  # Vertex indices.
  var thisrow = 0
  var prevrow = 0
  var point = 0

  var wx := 20
  var wy := 20
  var idx = 0
  for y in range(0, wy):
    for x in range(0, wx):
      # 0 -- 3
      # |    |
      # 1 -- 2
      var v0 := Vector2(x * grid_size, y * grid_size)
      verts.append(Vector2((x + 0) * grid_size, (y + 0) * grid_size)) # v0
      verts.append(Vector2((x + 0) * grid_size, (y + 1) * grid_size)) # v1
      verts.append(Vector2((x + 1) * grid_size, (y + 1) * grid_size)) # v2
      verts.append(Vector2((x + 1) * grid_size, (y + 0) * grid_size)) # v3
      uvs.append(Vector2(0, 0))
      uvs.append(Vector2(0, 1))
      uvs.append(Vector2(1, 1))
      uvs.append(Vector2(1, 0))
      # top left triangle  0 1 3
      indices.append(idx)
      indices.append(idx + 1)
      indices.append(idx + 3)
      # bottom right triangle 1 2 3
      indices.append(idx + 1)
      indices.append(idx + 2)
      indices.append(idx + 3)
      idx += 4

  # Assign arrays to surface array.
  surface_array[Mesh.ARRAY_VERTEX] = verts
  surface_array[Mesh.ARRAY_TEX_UV] = uvs
  #surface_array[Mesh.ARRAY_NORMAL] = normals
  surface_array[Mesh.ARRAY_INDEX] = indices

  # Create mesh surface from mesh array.
  # No blendshapes, lods, or compression used.
  meshInstance.mesh = ArrayMesh.new()
  meshInstance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
