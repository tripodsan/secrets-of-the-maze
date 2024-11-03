@tool
extends Polygon2D

@export var rebuild:bool = false:
  set(value):
    generate_mesh()

@export var grid_size:int = 32:
  set(value):
    grid_size = value
    generate_mesh()

var meshInstance: MeshInstance2D

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

  #get BB of polygon
  var x0:int = INF
  var x1:int = -INF
  var y0:int = INF
  var y1:int = -INF
  for v:Vector2 in polygon:
    x0 = min(x0, int(v.x) % grid_size)
    y0 = min(y0, int(v.y) % grid_size)
    x1 = max(x0, int(v.x) % grid_size + grid_size)
    y1 = max(y0, int(v.y) % grid_size + grid_size)

  # walk around the polygon in grid_size steps
  var i:int = 0
  var dist:float = 0
  var dest:PackedVector2Array = PackedVector2Array()
  while i < len(polygon):
    var v0:Vector2 = polygon[i]
    var v1:Vector2 = polygon[(i+1) % len(polygon)]
    while v0 != v1:
      dest.append(v0)
      v0 = v0.move_toward(v1, grid_size)
    i += 1
  $poly.polygon = dest
  var tri:PackedInt32Array = Geometry2D.triangulate_polygon(dest)
  prints('triangluation:', dest.size(), tri.size())
  var idx = 0
  for j in range(0, len(tri), 3):
    verts.append(dest[tri[j]])
    verts.append(dest[tri[j + 1]])
    verts.append(dest[tri[j + 2]])
    uvs.append(Vector2(0, 0))
    uvs.append(Vector2(0, 1))
    uvs.append(Vector2(1, 1))
    indices.append(j)
    indices.append(j + 1)
    indices.append(j + 2)


  #var wx := 20
  #var wy := 20
  #var idx = 0
  #for y in range(0, wy):
    #for x in range(0, wx):
      ## 0 -- 3
      ## |    |
      ## 1 -- 2
      #var v0 := Vector2(x * grid_size, y * grid_size)
      #verts.append(Vector2((x + 0) * grid_size, (y + 0) * grid_size)) # v0
      #verts.append(Vector2((x + 0) * grid_size, (y + 1) * grid_size)) # v1
      #verts.append(Vector2((x + 1) * grid_size, (y + 1) * grid_size)) # v2
      #verts.append(Vector2((x + 1) * grid_size, (y + 0) * grid_size)) # v3
      #uvs.append(Vector2(0, 0))
      #uvs.append(Vector2(0, 1))
      #uvs.append(Vector2(1, 1))
      #uvs.append(Vector2(1, 0))
      ## top left triangle  0 1 3
      #indices.append(idx)
      #indices.append(idx + 1)
      #indices.append(idx + 3)
      ## bottom right triangle 1 2 3
      #indices.append(idx + 1)
      #indices.append(idx + 2)
      #indices.append(idx + 3)
      #idx += 4

  # Assign arrays to surface array.
  surface_array[Mesh.ARRAY_VERTEX] = verts
  surface_array[Mesh.ARRAY_TEX_UV] = uvs
  #surface_array[Mesh.ARRAY_NORMAL] = normals
  surface_array[Mesh.ARRAY_INDEX] = indices

  # Create mesh surface from mesh array.
  # No blendshapes, lods, or compression used.
  meshInstance.mesh = ArrayMesh.new()
  meshInstance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, surface_array)
