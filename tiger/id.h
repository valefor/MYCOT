#ifndef _TG_ID_H
#define _TG_ID_H

#define ID_SCOPE_SHIFT 3
#define ID_SCOPE_MASK 0x07
#define ID_UNDEF    0x00
#define ID_VAR      0x01
#define ID_ARG      0x02
#define ID_TYPE     0x03
#define ID_FUNC     0x04
#define ID_FIELD    0x05

#define ID_PURE(id) (id) >> ID_SCOPE_SHIFT
#define ID_TRAN(id,type) (ID_PURE((id)) << ID_SCOPE_SHIFT ) | type

#endif
