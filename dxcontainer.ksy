meta:
  id: dxcontainer
  endian: le

seq:
  - id: magic
    contents: "DXBC"

  - id: hash
    size: 16

  - id: version_major
    type: u2

  - id: version_minor
    type: u2

  - id: file_size
    type: u4

  - id: part_count
    type: u4

  - id: part_offsets
    type: u4
    repeat: expr
    repeat-expr: part_count


instances:
  parts:
    type: part
    repeat: eos
    io: _root._io

types:
  part:
    seq:
      - id: fourcc
        size: 4
        type: str
        encoding: ASCII

      - id: size
        type: u4

      - id: data
        size: size
        type:
          switch-on: fourcc
          cases:
           '"DXIL"': dxil_part
           '"ILDB"': dxil_part
           '"ILDN"': ildn_part
           _: data_blob
            
    types:
      data_blob:
        seq:
        - id: data
          size: _parent.size
       
  ildn_part:
    seq:
      - id: flags
        type: u2

      - id: length
        type: u2

      - id: debug_name
        type: strz
        encoding: ASCII

  dxil_part:
    seq:
      - id: version
        type: u1

      - id: unused
        type: u1

      - id: shader_kind
        type: u2

      - id: size_in_u4
        type: u4

      - id: bitcode
        size: size_in_u4 * 4 - 8
        type: bitcode
      
    types:
      bitcode_header:
        seq:
            - id: magic
              size: 4
              contents: "DXIL"
              
            - id: minor_version
              type: u1
            
            - id: major_version
              type: u1
              
            - id: unused
              type: u2
              
            - id: offset
              type: u4
              
            - id: size
              type: u4

      bitcode:
        seq:
            - id: bc_header
              type: bitcode_header
              
            - id: bitcode
              size: bc_header.size
