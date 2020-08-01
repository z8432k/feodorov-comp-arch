  .globl func, prepare_args

  .data

mask: .long 0x00000001, 0x00000001, 0x00000001, 0x00000001

  .text

func:
  enter $0, $0
  push

  leave
  ret

# void prepare_args(uint8_t *a, uint8_t *b, uint8_t *c, uint8_t *d)
# {
#    *a = *a & 1;
#    *b = *b & 1;
#    *c = *c & 1;
#    *d = *d & 1;
# }
prepare_args:
  enter $0, $0
  xor %eax, %eax
  mov %eax, %ecx

  sub $8, %esp # stack align

  1:
  mov 8(%ebp,%ecx,4), %ebx
  mov (%ebx), %al
  push %eax
  inc %cl
  cmp $4, %cl
  jl 1b

  movdqa (%esp), %xmm0
  movdqa mask, %xmm1
  pand %xmm1, %xmm0 # SSE AND

  movdqa %xmm0, (%esp)

  1:
  dec %ecx
  js 1f
  mov 8(%ebp,%ecx,4), %ebx
  pop %eax
  mov %al, (%ebx)
  jmp 1b
  1:

  add $8, %esp # stack restore

  leave
  ret
# edx
#    a    b    c    d
# 0000 0000 0000 0001

# al
#      abcd
# 0000 0001
