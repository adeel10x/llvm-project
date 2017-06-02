; RUN: opt < %s -instcombine -S | FileCheck %s

define i32 @test1(i32 %A) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i32 %A
;
  %B = xor i32 %A, -1
  %C = xor i32 %B, -1
  ret i32 %C
}

define i1 @invert_icmp(i32 %A, i32 %B) {
; CHECK-LABEL: @invert_icmp(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 %A, %B
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %cmp = icmp sle i32 %A, %B
  %not = xor i1 %cmp, true
  ret i1 %not
}

; PR1570

define i1 @invert_fcmp(float %X, float %Y) {
; CHECK-LABEL: @invert_fcmp(
; CHECK-NEXT:    [[CMP:%.*]] = fcmp uge float %X, %Y
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %cmp = fcmp olt float %X, %Y
  %not = xor i1 %cmp, true
  ret i1 %not
}

; PR2298

define i1 @not_not_cmp(i32 %a, i32 %b) {
; CHECK-LABEL: @not_not_cmp(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i32 %b, %a
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %nota = xor i32 %a, -1
  %notb = xor i32 %b, -1
  %cmp = icmp slt i32 %nota, %notb
  ret i1 %cmp
}

define <2 x i1> @not_not_cmp_vector(<2 x i32> %a, <2 x i32> %b) {
; CHECK-LABEL: @not_not_cmp_vector(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ugt <2 x i32> %b, %a
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %nota = xor <2 x i32> %a, <i32 -1, i32 -1>
  %notb = xor <2 x i32> %b, <i32 -1, i32 -1>
  %cmp = icmp ugt <2 x i32> %nota, %notb
  ret <2 x i1> %cmp
}

define i1 @not_cmp_constant(i32 %a) {
; CHECK-LABEL: @not_cmp_constant(
; CHECK-NEXT:    [[CMP:%.*]] = icmp ult i32 %a, -43
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %nota = xor i32 %a, -1
  %cmp = icmp ugt i32 %nota, 42
  ret i1 %cmp
}

define <2 x i1> @not_cmp_constant_vector(<2 x i32> %a) {
; CHECK-LABEL: @not_cmp_constant_vector(
; CHECK-NEXT:    [[NOTA:%.*]] = xor <2 x i32> %a, <i32 -1, i32 -1>
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt <2 x i32> [[NOTA]], <i32 42, i32 42>
; CHECK-NEXT:    ret <2 x i1> [[CMP]]
;
  %nota = xor <2 x i32> %a, <i32 -1, i32 -1>
  %cmp = icmp slt <2 x i32> %nota, <i32 42, i32 42>
  ret <2 x i1> %cmp
}

define <2 x i1> @test7(<2 x i32> %A, <2 x i32> %B) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    [[COND:%.*]] = icmp sgt <2 x i32> %A, %B
; CHECK-NEXT:    ret <2 x i1> [[COND]]
;
  %cond = icmp sle <2 x i32> %A, %B
  %Ret = xor <2 x i1> %cond, <i1 true, i1 true>
  ret <2 x i1> %Ret
}

define i32 @not_ashr_not(i32 %A, i32 %B) {
; CHECK-LABEL: @not_ashr_not(
; CHECK-NEXT:    [[NOT2:%.*]] = ashr i32 %A, %B
; CHECK-NEXT:    ret i32 [[NOT2]]
;
  %not1 = xor i32 %A, -1
  %ashr = ashr i32 %not1, %B
  %not2 = xor i32 %ashr, -1
  ret i32 %not2
}

define i8 @not_ashr_const(i8 %x) {
; CHECK-LABEL: @not_ashr_const(
; CHECK-NEXT:    [[NOT:%.*]] = lshr i8 41, %x
; CHECK-NEXT:    ret i8 [[NOT]]
;
  %shr = ashr i8 -42, %x
  %not = xor i8 %shr, -1
  ret i8 %not
}

define <2 x i8> @not_ashr_const_splat(<2 x i8> %x) {
; CHECK-LABEL: @not_ashr_const_splat(
; CHECK-NEXT:    [[NOT:%.*]] = lshr <2 x i8> <i8 41, i8 41>, %x
; CHECK-NEXT:    ret <2 x i8> [[NOT]]
;
  %shr = ashr <2 x i8> <i8 -42, i8 -42>, %x
  %not = xor <2 x i8> %shr, <i8 -1, i8 -1>
  ret <2 x i8> %not
}

; We can't get rid of the 'not' on a logical shift of a negative constant.

define i8 @not_lshr_const_negative(i8 %x) {
; CHECK-LABEL: @not_lshr_const_negative(
; CHECK-NEXT:    [[SHR:%.*]] = lshr i8 -42, %x
; CHECK-NEXT:    [[NOT:%.*]] = xor i8 [[SHR]], -1
; CHECK-NEXT:    ret i8 [[NOT]]
;
  %shr = lshr i8 -42, %x
  %not = xor i8 %shr, -1
  ret i8 %not
}

define i8 @not_lshr_const(i8 %x) {
; CHECK-LABEL: @not_lshr_const(
; CHECK-NEXT:    [[NOT:%.*]] = ashr i8 -43, %x
; CHECK-NEXT:    ret i8 [[NOT]]
;
  %shr = lshr i8 42, %x
  %not = xor i8 %shr, -1
  ret i8 %not
}

define <2 x i8> @not_lshr_const_splat(<2 x i8> %x) {
; CHECK-LABEL: @not_lshr_const_splat(
; CHECK-NEXT:    [[NOT:%.*]] = ashr <2 x i8> <i8 -43, i8 -43>, %x
; CHECK-NEXT:    ret <2 x i8> [[NOT]]
;
  %shr = lshr <2 x i8> <i8 42, i8 42>, %x
  %not = xor <2 x i8> %shr, <i8 -1, i8 -1>
  ret <2 x i8> %not
}

