\m4_TLV_version 1d: tl-x.org
\SV
// v====================== lib/risc-v_shell_lib.tlv =======================v

// Configuration for WARP-V definitions.
m4+definitions(['
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/warp-v_includes/1d1023ccf8e7b0a8cf8e8fc4f0a823ebb61008e3/risc-v_defs.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_lib/db48b4c22c4846c900b3fa307e87d9744424d916/fundamentals_lib.tlv'])

   // Access a signal and if it is missing and expected to exist, add it to the missing signals list.
   m4_func(siggen, sig_name, sig_path, expected, ['
      m4_def(sigs_list, m4_quote(m4_sigs_list)[', ']m4_sig_path['$']m4_sig_name)
      m4_def(bogus_sigs_list, m4_quote(m4_bogus_sigs_list)[' ']m4_sig_path['$']m4_sig_name)
      m4_ifelse(m4_expected, [''], ['
         m4_output(['sigref("$']m4_sig_name['", '']m4_sig_path['$']m4_sig_name['', this.svSigRef("CPU_MissingSignals_']m4_sig_name['_a0"))'])
      '], ['
           
         m4_output([''']m4_sig_path['$']m4_sig_name['''])
      '])
   '])
   m4_def(sigs_list, ['$dummy'])
   m4_def(bogus_sigs_list, ['$dummy'])

   // Define full test program.
   // Provide a non-empty argument if this is instantiated within a \TLV region (vs. \SV).
   m4_define(['m4_test_prog'], ['m4_hide(['
     // /=======================\
     // | Test each instruction |
     // \=======================/
     //
     // Some constant values to use as operands.
     m4_asm(ADDI, x1, x0, 10101)           // An operand value of 21.
     m4_asm(ADDI, x2, x0, 111)             // An operand value of 7.
     m4_asm(ADDI, x3, x0, 111111111100)    // An operand value of -4.
     // Execute one of each instruction, XORing subtracting (via ADDI) the expected value.
     // ANDI:
     m4_asm(ANDI, x5, x1, 1011100)
     m4_asm(XORI, x5, x5, 10101)
     // ORI:
     m4_asm(ORI, x6, x1, 1011100)
     m4_asm(XORI, x6, x6, 1011100)
     // ADDI:
     m4_asm(ADDI, x7, x1, 111)
     m4_asm(XORI, x7, x7, 11101)
     // ADDI:
     m4_asm(SLLI, x8, x1, 110)
     m4_asm(XORI, x8, x8, 10101000001)
     // SLLI:
     m4_asm(SRLI, x9, x1, 10)
     m4_asm(XORI, x9, x9, 100)
     // AND:
     m4_asm(AND, r10, x1, x2)
     m4_asm(XORI, x10, x10, 100)
     // OR:
     m4_asm(OR, x11, x1, x2)
     m4_asm(XORI, x11, x11, 10110)
     // XOR:
     m4_asm(XOR, x12, x1, x2)
     m4_asm(XORI, x12, x12, 10011)
     // ADD:
     m4_asm(ADD, x13, x1, x2)
     m4_asm(XORI, x13, x13, 11101)
     // SUB:
     m4_asm(SUB, x14, x1, x2)
     m4_asm(XORI, x14, x14, 1111)
     // SLL:
     m4_asm(SLL, x15, x2, x2)
     m4_asm(XORI, x15, x15, 1110000001)
     // SRL:
     m4_asm(SRL, x16, x1, x2)
     m4_asm(XORI, x16, x16, 1)
     // SLTU:
     m4_asm(SLTU, x17, x2, x1)
     m4_asm(XORI, x17, x17, 0)
     // SLTIU:
     m4_asm(SLTIU, x18, x2, 10101)
     m4_asm(XORI, x18, x18, 0)
     // LUI:
     m4_asm(LUI, x19, 0)
     m4_asm(XORI, x19, x19, 1)
     // SRAI:
     m4_asm(SRAI, x20, x3, 1)
     m4_asm(XORI, x20, x20, 111111111111)
     // SLT:
     m4_asm(SLT, x21, x3, x1)
     m4_asm(XORI, x21, x21, 0)
     // SLTI:
     m4_asm(SLTI, x22, x3, 1)
     m4_asm(XORI, x22, x22, 0)
     // SRA:
     m4_asm(SRA, x23, x1, x2)
     m4_asm(XORI, x23, x23, 1)
     // AUIPC:
     m4_asm(AUIPC, x4, 100)
     m4_asm(SRLI, x24, x4, 111)
     m4_asm(XORI, x24, x24, 10000000)
     // JAL:
     m4_asm(JAL, x25, 10)     // x25 = PC of next instr
     m4_asm(AUIPC, x4, 0)     // x4 = PC
     m4_asm(XOR, x25, x25, x4)  # AUIPC and JAR results are the same.
     m4_asm(XORI, x25, x25, 1)
     // JALR:
     m4_asm(JALR, x26, x4, 10000)
     m4_asm(SUB, x26, x26, x4)        // JALR PC+4 - AUIPC PC
     m4_asm(ADDI, x26, x26, 111111110001)  // - 4 instrs, + 1
     // SW & LW:
     m4_asm(SW, x2, x1, 1)
     m4_asm(LW, x27, x2, 1)
     m4_asm(XORI, x27, x27, 10100)
     // Write 1 to remaining registers prior to x30 just to avoid concern.
     m4_asm(ADDI, x28, x0, 1)
     m4_asm(ADDI, x29, x0, 1)
     // Terminate with success condition (regardless of correctness of register values):
     m4_asm(ADDI, x30, x0, 1)
     m4_asm(BGE, x0, x0, 0) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
     
     m4_define(['M4_VIZ_BASE'], 16)   // (Note that immediate values are shown in disassembled instructions in binary and signed decimal in decoder regardless of this setting.)

     m4_define(['M4_MAX_CYC'], 70)
     '])m4_ifelse(['$1'], [''], ['m4_asm_end()'], ['m4_asm_end_tlv()'])'])
   
   m4_define_vector(['M4_WORD'], 32)
   m4_define(['M4_EXT_I'], 1)
   
   m4_define(['M4_NUM_INSTRS'], 0)
   
   m4_echo(m4tlv_riscv_gen__body())
   
   // A single-line M4 macro instantiated at the end of the asm code.
   // It actually produces a definition of an SV macro that instantiates the IMem conaining the program (that can be parsed without \SV_plus). 
   m4_define(['m4_asm_end'], ['`define READONLY_MEM(ADDR, DATA) logic [31:0] instrs [0:M4_NUM_INSTRS-1]; assign DATA = instrs[ADDR[$clog2($size(instrs)) + 1 : 2]]; assign instrs = '{m4_instr0['']m4_forloop(['m4_instr_ind'], 1, M4_NUM_INSTRS, [', m4_echo(['m4_instr']m4_instr_ind)'])};'])
   m4_define(['m4_asm_end_tlv'], ['`define READONLY_MEM(ADDR, DATA) logic [31:0] instrs [0:M4_NUM_INSTRS-1]; assign DATA \= instrs[ADDR[\$clog2(\$size(instrs)) + 1 : 2]]; assign instrs \= '{m4_instr0['']m4_forloop(['m4_instr_ind'], 1, M4_NUM_INSTRS, [', m4_echo(['m4_instr']m4_instr_ind)'])};'])
'])

\TLV test_prog()
   m4_test_prog(['TLV'])

// Register File
\TLV rf(@_rd, @_wr, $_reset, $_wr_en, $_wr_index, $_wr_data, $_rd1_en, $_rd1_index, $_rd1_data, $_rd2_en, $_rd2_index, $_rd2_data)
   @_wr
      $rf1_wr_en = $_wr_en;
      $rf1_wr_index[4:0]  = $_wr_index;
      $rf1_wr_data[31:0] = $_wr_data;
   @_rd
      $rf1_rd_en1 = $_rd1_en;
      $rf1_rd_index1[4:0] = $_rd1_index;

      $rf1_rd_en2 = $_rd2_en;
      $rf1_rd_index2[4:0] = $_rd2_index;
   
   @_wr
      /xreg[31:0]
         $wr = |cpu$rf1_wr_en && (|cpu$rf1_wr_index == #xreg);
         <<1$value[31:0] = |cpu$_reset ? #xreg              :
                           $wr         ? |cpu$rf1_wr_data :
                                         $RETAIN;
   @_rd
      $_rd1_data[31:0]  =  $rf1_rd_en1 ? /xreg[$rf1_rd_index1]>>m4_stage_eval(@_wr - @_rd)$value : 'X;
      $_rd2_data[31:0]  =  $rf1_rd_en2 ? /xreg[$rf1_rd_index2]>>m4_stage_eval(@_wr - @_rd)$value : 'X;

\TLV tb()
   $passed_cond = (/xreg[30]$value == 32'b1) && $valid && $taken_br && $br_tgt_pc == $pc && ! $reset;
   *passed = >>2$passed_cond;

// Data Memory
\TLV dmem($_reset, $_addr, $_port1_en, $_port1_data, $_port2_en, $_port2_data)
   // Allow expressions for most inputs, so define input signals.
   $dmem1_wr_en = $_port1_en;
   $dmem1_addr[4:0] = $_addr;
   $dmem1_wr_data[31:0] = $_port1_data;
   
   $dmem1_rd_en = $_port2_en;
   
   /dmem[31:0]
      $wr = |cpu$dmem1_wr_en && (|cpu$dmem1_addr == #dmem);
      <<1$value[31:0] = |cpu$_reset ? 0                 :
                        $wr         ? |cpu$dmem1_wr_data :
                                      $RETAIN;
   
   $_port2_data[31:0] = $dmem1_rd_en ? /dmem[$dmem1_addr]$value : 'X;
   

\TLV cpu_viz(#show_viz_in_diagram)
   m4+ifelse(m4_ifdef(['m4_sp_graph_dangerous'], m4_sp_graph_dangerous, 0)#show_viz_in_diagram, 10, [''],
      \TLV
         // String representations of the instructions for debug.
         \SV_plus
            // A default signal for ones that are not found.
            logic sticky_zero;
            assign sticky_zero = 0;
            // Instruction strings from the assembler.
            logic [40*8-1:0] instr_strs [0:M4_NUM_INSTRS];
            assign instr_strs = '{m4_asm_mem_expr "END                                     "};
   
         /cpu_viz
            $ANY = |cpu$ANY;
            \viz_alpha
               m4_define(['M4_IMEM_TOP'], ['m4_ifelse(m4_eval(M4_NUM_INSTRS > 16), 0, 0, m4_eval(0 - (M4_NUM_INSTRS - 16) * 18))'])
               initEach() {
                  let imem_box = new fabric.Rect({
                        top: M4_IMEM_TOP - 50,
                        left: -700,
                        fill: "#208028",
                        width: 665,
                        height: 76 + 18 * M4_NUM_INSTRS,
                        stroke: "black",
                        visible: false
                     })
                  let decode_box = new fabric.Rect({
                        top: -25,
                        left: -15,
                        fill: "#f8f0e8",
                        width: 280,
                        height: 215,
                        stroke: "#ff8060",
                        visible: false
                     })
                  let rf_box = new fabric.Rect({
                        top: -90,
                        left: 306,
                        fill: "#2028b0",
                        width: 145,
                        height: 650,
                        stroke: "black",
                        visible: false
                     })
                  let dmem_box = new fabric.Rect({
                        top: -90,
                        left: 470,
                        fill: "#208028",
                        width: 145,
                        height: 650,
                        stroke: "black",
                        visible: false
                     })
                  let imem_header = new fabric.Text("🗃️ IMem", {
                        top: M4_IMEM_TOP - 35,
                        left: -460,
                        fontSize: 18,
                        fontWeight: 800,
                        fontFamily: "monospace",
                        fill: "white",
                        visible: false
                     })
                  let decode_header = new fabric.Text("⚙️ Instr. Decode", {
                        top: -4,
                        left: 20,
                        fill: "maroon",
                        fontSize: 18,
                        fontWeight: 800,
                        fontFamily: "monospace",
                        visible: false
                     })
                  let rf_header = new fabric.Text("📂 RF", {
                        top: -75,
                        left: 316,
                        fontSize: 18,
                        fontWeight: 800,
                        fontFamily: "monospace",
                        fill: "white",
                        visible: false
                     })
                  let dmem_header = new fabric.Text("🗃️ DMem", {
                        top: -75,
                        left: 480,
                        fontSize: 18,
                        fontWeight: 800,
                        fontFamily: "monospace",
                        fill: "white",
                        visible: false
                     })
   
                  let passed = new fabric.Text("", {
                        top: 340,
                        left: -30,
                        fontSize: 46,
                        fontWeight: 800
                     })
                  let missing_col1 = new fabric.Text("", {
                        top: 420,
                        left: -480,
                        fontSize: 16,
                        fontWeight: 500,
                        fontFamily: "monospace",
                        fill: "purple"
                     })
                  let missing_col2 = new fabric.Text("", {
                        top: 420,
                        left: -300,
                        fontSize: 16,
                        fontWeight: 500,
                        fontFamily: "monospace",
                        fill: "purple"
                     })
                  let missing_sigs = new fabric.Group(
                     [new fabric.Text("🚨 To Be Implemented:", {
                        top: 350,
                        left: -466,
                        fontSize: 18,
                        fontWeight: 800,
                        fill: "red",
                        fontFamily: "monospace"
                     }),
                     new fabric.Rect({
                        top: 400,
                        left: -500,
                        fill: "#ffffe0",
                        width: 400,
                        height: 300,
                        stroke: "black"
                     }),
                     missing_col1,
                     missing_col2,
                    ],
                    {visible: false}
                  )
                  return {missing_col1, missing_col2,
                          objects: {imem_box, decode_box, rf_box, dmem_box, imem_header, decode_header, rf_header, dmem_header, passed, missing_sigs}};
               },
               renderEach() {
                  // Strings (2 columns) of missing signals.
                  var missing_list = ["", ""]
                  var missing_cnt = 0
                  let sticky_zero = this.svSigRef(`sticky_zero`);  // A default zero-valued signal.
                  // Attempt to look up a signal, using sticky_zero as default and updating missing_list if expected.
                  sigref = (sig_name, sig, missing_sig) => {
                     if (missing_sig != null) {
                        missing_list[missing_cnt > 11 ? 1 : 0] += `◾ ${sig_name}      \n`
                        missing_cnt++
                     }
                     return sig
                  }
                  // Look up signal, and it's ok if it doesn't exist.
                  siggen_rf_dmem = (name, scope) => {
                     return siggen(name, scope, false)
                  }
   
                  // Determine which is_xxx signal is asserted.
                  siggen_mnemonic = () => {
                     is_instr = (sig) => {
                        return sig != null && sig.asBool()
                     }
                     return is_instr('$is_lui') ? "LUI" :
                        is_instr('$is_auipc') ? "AUIPC" :
                        is_instr('$is_jal') ? "JAL" :
                        is_instr('$is_jalr') ? "JALR" :
                        is_instr('$is_beq') ? "BEQ" :
                        is_instr('$is_bne') ? "BNE" :
                        is_instr('$is_blt') ? "BLT" :
                        is_instr('$is_bge') ? "BGE" :
                        is_instr('$is_bltu') ? "BLTU" :
                        is_instr('$is_bgeu') ? "BGEU" :
                        is_instr('$is_addi') ? "ADDI" :
                        is_instr('$is_slti') ? "SLTI" :
                        is_instr('$is_sltiu') ? "SLTIU" :
                        is_instr('$is_xori') ? "XORI" :
                        is_instr('$is_ori') ? "ORI" :
                        is_instr('$is_andi') ? "ANDI" :
                        is_instr('$is_slli') ? "SLLI" :
                        is_instr('$is_srli') ? "SRLI" :
                        is_instr('$is_srai') ? "SRAI" :
                        is_instr('$is_add') ? "ADD" :
                        is_instr('$is_sub') ? "SUB" :
                        is_instr('$is_sll') ? "SLL" :
                        is_instr('$is_slt') ? "SLT" :
                        is_instr('$is_sltu') ? "SLTU" :
                        is_instr('$is_xor') ? "XOR" :
                        is_instr('$is_srl') ? "SRL" :
                        is_instr('$is_sra') ? "SRA" :
                        is_instr('$is_or') ? "OR" :
                        is_instr('$is_and') ? "AND" :
                        is_instr('$is_load') ? "LOAD" :
                        is_instr('$is_s_instr') ? "STORE" :
                                "ILLEGAL"
                  }
                  let valid         =   '$valid'.asBool(false)
                  let pc            =   m4_siggen(pc)
                  let instr         =   m4_siggen(instr)
                  let types = {I: m4_siggen(is_i_instr),
                               R: m4_siggen(is_r_instr),
                               S: m4_siggen(is_s_instr),
                               B: m4_siggen(is_b_instr),
                               J: m4_siggen(is_j_instr),
                               U: m4_siggen(is_u_instr),
                              }
                  let rd_valid      =   m4_siggen(rd_valid)
                  let rd            =   m4_siggen(rd)
                  let result        =   m4_siggen(result)
                  let src1_value    =   m4_siggen(src1_value)
                  let src2_value    =   m4_siggen(src2_value)
                  let imm           =   m4_siggen(imm)
                  let imm_valid     =   m4_siggen(imm_valid)
                  let rs1           =   m4_siggen(rs1)
                  let rs2           =   m4_siggen(rs2)
                  let rs1_valid     =   m4_siggen(rs1_valid)
                  let rs2_valid     =   m4_siggen(rs2_valid)
                  let ld_data       =   m4_siggen(ld_data)
                  let mnemonic      =   siggen_mnemonic()
                  let passed        =   m4_siggen(passed_cond, , false)
   
                  let rf_rd_en1     =   '$rf1_rd_en1'
                  let rf_rd_index1  =   '$rf1_rd_index1'
                  let rf_rd_en2     =   '$rf1_rd_en2'
                  let rf_rd_index2  =   '$rf1_rd_index2'
                  let rf_wr_en      =   '$rf1_wr_en'
                  let rf_wr_index   =   '$rf1_wr_index'
                  let rf_wr_data    =   '$rf1_wr_data'
                  let dmem_rd_en    =   '$dmem1_rd_en'
                  let dmem_wr_en    =   '$dmem1_wr_en'
                  let dmem_addr     =   '$dmem1_addr'
                  
                  let color = valid ? "blue" : "gray"
   
                  if (instr != sticky_zero) {
                     this.getInitObjects().imem_box.setVisible(true)
                     this.getInitObjects().imem_header.setVisible(true)
                     this.getInitObjects().decode_box.setVisible(true)
                     this.getInitObjects().decode_header.setVisible(true)
                  }
                  let pcPointer = new fabric.Text("👉", {
                     top: M4_IMEM_TOP + 18 * (pc.asInt() / 4),
                     left: -375,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace",
                     visible: pc != sticky_zero
                  })
                  let pc_arrow = new fabric.Line([-57, M4_IMEM_TOP + 18 * (pc.asInt() / 4) + 6, 6, 35], {
                     stroke: "#b0c8df",
                     strokeWidth: 2,
                     visible: instr != sticky_zero
                  })
   
                  // Display instruction type(s)
                  let type_texts = []
                  for (const [type, sig] of Object.entries(types)) {
                     if (sig.asBool()) {
                        type_texts.push(
                           new fabric.Text(`(${type})`, {
                              top: 60,
                              left: 10,
                              fill: color,
                              fontSize: 20,
                              fontFamily: "monospace"
                           })
                        )
                     }
                  }
                  debugger
                  let rs1_arrow = new fabric.Line([330, 18 * rf_rd_index1.asInt() + 6 - 40, 190, 75 + 18 * 2], {
                     stroke: "#b0c8df",
                     strokeWidth: 2,
                     visible: rf_rd_en1.asBool()
                  })
                  let rs2_arrow = new fabric.Line([330, 18 * rf_rd_index2.asInt() + 6 - 40, 190, 75 + 18 * 3], {
                     stroke: "#b0c8df",
                     strokeWidth: 2,
                     visible: rf_rd_en2.asBool()
                  })
                  let rd_arrow = new fabric.Line([330, 18 * rf_wr_index.asInt() + 6 - 40, 168, 75 + 18 * 0], {
                     stroke: "#b0b0df",
                     strokeWidth: 3,
                     visible: rf_wr_en.asBool()
                  })
                  let ld_arrow = new fabric.Line([490, 18 * dmem_addr.asInt() + 6 - 40, 168, 75 + 18 * 0], {
                     stroke: "#b0c8df",
                     strokeWidth: 2,
                     visible: dmem_rd_en.asBool()
                  })
                  let st_arrow = new fabric.Line([490, 18 * dmem_addr.asInt() + 6 - 40, 190, 75 + 18 * 3], {
                     stroke: "#b0b0df",
                     strokeWidth: 3,
                     visible: dmem_wr_en.asBool()
                  })
                  if (rf_rd_en1 != sticky_zero) {
                     this.getInitObjects().rf_box.setVisible(true)
                     this.getInitObjects().rf_header.setVisible(true)
                  }
                  if (dmem_rd_en != sticky_zero) {
                     this.getInitObjects().dmem_box.setVisible(true)
                     this.getInitObjects().dmem_header.setVisible(true)
                  }
   
   
                  // Instruction with values
   
                  let regStr = (valid, regNum, regValue) => {
                     return valid ? `x${regNum}` : `xX`  // valid ? `x${regNum} (${regValue})` : `xX`
                  }
                  let immStr = (valid, immValue) => {
                     immValue = parseInt(immValue,2) + 2*(immValue[0] << 31)
                     return valid ? `i[${immValue}]` : ``;
                  }
                  let srcStr = ($src, $valid, $reg, $value) => {
                     return $valid.asBool(false)
                                ? `\n      ${regStr(true, $reg.asInt(NaN), $value.asInt(NaN))}`
                                : "";
                  }
                  let str = `${regStr(rd_valid.asBool(false), rd.asInt(NaN), result.asInt(NaN))}\n` +
                            `  = ${mnemonic}${srcStr(1, rs1_valid, rs1, src1_value)}${srcStr(2, rs2_valid, rs2, src2_value)}\n` +
                            `      ${immStr(imm_valid.asBool(false), imm.asBinaryStr("0"))}`;
                  let instrWithValues = new fabric.Text(str, {
                     top: 70,
                     left: 65,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace",
                     visible: instr != sticky_zero
                  })
   
   
                  // Animate fetch (and provide onChange behavior for other animation).
   
                  let fetch_instr_sig = this.svSigRef(`instr_strs(${pc.asInt() >> 2})`)
                  let fetch_instr_str = fetch_instr_sig ? fetch_instr_sig.asString("(?) UNKNOWN fetch instr").substr(4) : "UNKNOWN fetch instr"
                  let fetch_instr_viz = new fabric.Text(fetch_instr_str, {
                     top: M4_IMEM_TOP + 18 * (pc.asInt() >> 2),
                     left: -352 + 8 * 4,
                     fill: valid ? "black" : "gray",
                     fontSize: 14,
                     fontFamily: "monospace",
                     visible: instr != sticky_zero
                  })
                  fetch_instr_viz.animate({top: 32, left: 10}, {
                       onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                       duration: 500
                  })
   
                  // Animate RF value read/write.
   
                  let src1_value_viz = new fabric.Text(src1_value.asInt(0).toString(M4_VIZ_BASE), {
                     left: 316 + 8 * 4,
                     top: 18 * rs1.asInt(0) - 40,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 800,
                     visible: (src1_value != sticky_zero) && rs1_valid.asBool(false)
                  })
                  setTimeout(() => {src1_value_viz.animate({left: 166, top: 70 + 18 * 2}, {
                       onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                       duration: 500
                  })}, 500)
                  let src2_value_viz = new fabric.Text(src2_value.asInt(0).toString(M4_VIZ_BASE), {
                     left: 316 + 8 * 4,
                     top: 18 * rs2.asInt(0) - 40,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 800,
                     visible: (src2_value != sticky_zero) && rs2_valid.asBool(false)
                  })
                  setTimeout(() => {src2_value_viz.animate({left: 166, top: 70 + 18 * 3}, {
                       onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                       duration: 500
                  })}, 500)
   
                  let load_viz = new fabric.Text(ld_data.asInt(0).toString(M4_VIZ_BASE), {
                     left: 470,
                     top: 18 * dmem_addr.asInt() + 6 - 40,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 1000,
                     visible: false
                  })
                  if (dmem_rd_en.asBool()) {
                     setTimeout(() => {
                        load_viz.setVisible(true)
                        load_viz.animate({left: 146, top: 70}, {
                          onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                          duration: 500
                        })
                        setTimeout(() => {
                           load_viz.setVisible(false)
                           }, 500)
                     }, 500)
                  }
   
                  let store_viz = new fabric.Text(src2_value.asInt(0).toString(M4_VIZ_BASE), {
                     left: 166,
                     top: 70 + 18 * 3,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 1000,
                     visible: false
                  })
                  if (dmem_wr_en.asBool()) {
                     setTimeout(() => {
                        store_viz.setVisible(true)
                        store_viz.animate({left: 515, top: 18 * dmem_addr.asInt() - 40}, {
                          onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                          duration: 500
                        })
                     }, 1000)
                  }
   
                  let result_shadow = new fabric.Text(result.asInt(0).toString(M4_VIZ_BASE), {
                     left: 146,
                     top: 70,
                     fill: "#b0b0df",
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 800,
                     visible: false
                  })
                  let result_viz = new fabric.Text(rf_wr_data.asInt(0).toString(M4_VIZ_BASE), {
                     left: 146,
                     top: 70,
                     fill: color,
                     fontSize: 14,
                     fontFamily: "monospace",
                     fontWeight: 800,
                     visible: false
                  })
                  if (rd_valid.asBool()) {
                     setTimeout(() => {
                        result_viz.setVisible(rf_wr_data != sticky_zero && rf_wr_en.asBool())
                        result_shadow.setVisible(result != sticky_zero)
                        result_viz.animate({left: 317 + 8 * 4, top: 18 * rf_wr_index.asInt(0) - 40}, {
                          onChange: this.global.canvas.renderAll.bind(this.global.canvas),
                          duration: 500
                        })
                     }, 1000)
                  }
   
                  // Lab completion
   
                  // Passed?
                  this.getInitObject("passed").setVisible(false)
                  if (passed) {
                    if (passed.step(-1).asBool()) {
                      this.getInitObject("passed").set({visible: true, text:"Passed !!!", fill: "green"})
                    } else {
                      // Using an unstable API, so:
                      try {
                        passed.goToSimEnd().step(-1)
                        if (passed.asBool()) {
                           this.getInitObject("passed").set({text:"Sim Passes", visible: true, fill: "lightgray"})
                        }
                      } catch(e) {
                      }
                    }
                  }
   
                  // Missing signals
                  if (missing_list[0]) {
                     this.getInitObject("missing_sigs").setVisible(true)
                     this.fromInit().missing_col1.setText(missing_list[0])
                     this.fromInit().missing_col2.setText(missing_list[1])
                  }
                  return {objects: [pcPointer, pc_arrow, ...type_texts, rs1_arrow, rs2_arrow, rd_arrow, instrWithValues, fetch_instr_viz, src1_value_viz, src2_value_viz, result_shadow, result_viz, ld_arrow, st_arrow, load_viz, store_viz]};
               }
   
   
            /imem[m4_eval(M4_NUM_INSTRS-1):0]
               \viz_alpha
                  initEach() {
                    let binary = new fabric.Text("", {
                       top: M4_IMEM_TOP + 18 * this.getIndex(),
                       left: -680,
                       fontSize: 14,
                       fontFamily: "monospace",
   
                    })
                    let disassembled = new fabric.Text("", {
                       top: M4_IMEM_TOP + 18 * this.getIndex(),
                       left: -350,
                       fontSize: 14,
                       fontFamily: "monospace"
                    })
                    return {objects: {binary, disassembled}}
                  },
                  renderEach() {
                     // Instruction memory is constant, so just create it once.
                     let reset = '|cpu$reset'
                     let pc = '|cpu$pc'
                     let rd_viz = pc && !reset.asBool() && (pc.asInt() >> 2) == this.getIndex()
                     if (!global.instr_mem_drawn) {
                        global.instr_mem_drawn = []
                     }
                     if (!global.instr_mem_drawn[this.getIndex()]) {
                        global.instr_mem_drawn[this.getIndex()] = true
   
                        let instr = this.svSigRef(`instrs(${this.getIndex()})`)
                        if (instr) {
                           let binary_str = instr.goToSimStart().asBinaryStr("")
                           this.getInitObject("binary").setText(binary_str)
                        }
                        let disassembled = this.svSigRef(`instr_strs(${this.getIndex()})`)
                        if (disassembled) {
                           let disassembled_str = disassembled.goToSimStart().asString("")
                           disassembled_str = disassembled_str.slice(0, -5)
                           this.getInitObject("disassembled").setText(disassembled_str)
                        }
                     }
                     this.getInitObject("disassembled").set({textBackgroundColor: rd_viz ? "#b0ffff" : "white"})
                     this.getInitObject("binary")      .set({textBackgroundColor: rd_viz ? "#b0ffff" : "white"})
                  }
            /xreg[31:0]
               $ANY = |cpu/xreg$ANY;
               \viz_alpha
                  initEach: function() {
                     return {}  // {objects: {reg: reg}};
                  },
                  renderEach: function() {
                     siggen = (name) => this.svSigRef(`${name}`) == null ? this.svSigRef(`sticky_zero`) : this.svSigRef(`${name}`);
                     
                     let rf_rd_en1 = '|cpu$rf1_rd_en1'
                     let rf_rd_index1 = '|cpu$rf1_rd_index1'
                     let rf_rd_en2 = '|cpu$rf1_rd_en2'
                     let rf_rd_index2 = '|cpu$rf1_rd_index2'
                     let rf_wr_index = '|cpu$rf1_wr_index'
                     let wr = '$wr'
                     let value = '$value'
                     //
                     let rd = (rf_rd_en1.asBool(false) && rf_rd_index1.asInt() == this.getIndex()) || 
                              (rf_rd_en2.asBool(false) && rf_rd_index2.asInt() == this.getIndex())
                     //
                     let mod = wr.asBool(false);
                     let reg = parseInt(this.getIndex())
                     let regIdent = reg.toString().padEnd(2, " ")
                     let newValStr = (regIdent + ": ").padEnd(14, " ")
                     let reg_str = new fabric.Text((regIdent + ": " + value.asInt(NaN).toString(M4_VIZ_BASE)).padEnd(14, " "), {
                        top: 18 * this.getIndex() - 40,
                        left: 316,
                        fontSize: 14,
                        fill: mod ? "blue" : "black",
                        fontWeight: mod ? 800 : 400,
                        fontFamily: "monospace",
                        textBackgroundColor: rd ? "#b0ffff" : mod ? "#f0f0f0" : "white"
                     })
                     if (mod) {
                        setTimeout(() => {
                           reg_str.set({text: newValStr, textBackgroundColor: "#d0e8ff", dirty: true})
                           this.global.canvas.renderAll()
                        }, 1500)
                     }
                     return {objects: [reg_str]}
                  }
            /dmem[31:0]
               $ANY = |cpu/dmem$ANY;
               \viz_alpha
                  initEach: function() {
                     return {}  // {objects: {reg: reg}};
                  },
                  renderEach: function() {
                     siggen = (name) => this.svSigRef(`${name}`) == null ? this.svSigRef(`sticky_zero`) : this.svSigRef(`${name}`);
                     //
                     let dmem_rd_en = '|cpu$dmem1_rd_en'
                     let dmem_addr = '|cpu$dmem1_addr'
                     //
                     let wr = '$wr'
                     let value = '$value'
                     //
                     let rd = dmem_rd_en.asBool() && dmem_addr.asInt() == this.getIndex();
                     let mod = wr.asBool(false);
                     let reg = parseInt(this.getIndex());
                     let regIdent = reg.toString().padEnd(2, " ");
                     let newValStr = (regIdent + ": ").padEnd(14, " ");
                     let dmem_str = new fabric.Text((regIdent + ": " + value.asInt(NaN).toString(M4_VIZ_BASE)).padEnd(14, " "), {
                        top: 18 * this.getIndex() - 40,
                        left: 480,
                        fontSize: 14,
                        fill: mod ? "blue" : "black",
                        fontWeight: mod ? 800 : 400,
                        fontFamily: "monospace",
                        textBackgroundColor: rd ? "#b0ffff" : mod ? "#d0e8ff" : "white"
                     })
                     if (mod) {
                        setTimeout(() => {
                           dmem_str.set({text: newValStr, dirty: true})
                           this.global.canvas.renderAll()
                        }, 1500)
                     }
                     return {objects: [dmem_str]}
                  }
         
            // Provide missing signals.
            /defaults
               {m4_sigs_list} = '0;
               {$is_lui, $is_auipc, $is_jal, $is_jalr, $is_beq, $is_bne, $is_blt, $is_bge, $is_bltu, $is_bgeu,
                  $is_addi, $is_slti, $is_sltiu, $is_xori, $is_ori, $is_andi, $is_slli, $is_srli, $is_srai, $is_add,
                  $is_sub, $is_sll, $is_slt, $is_sltu, $is_xor, $is_srl, $is_sra, $is_or, $is_and, $is_load} = '0;
               $valid = 1'b1;   // Non-zero, special-case.
               `BOGUS_USE($valid m4_bogus_sigs_list)
               `BOGUS_USE($is_lui $is_auipc $is_jal $is_jalr $is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu
                  $is_addi $is_slti $is_sltiu $is_xori $is_ori $is_andi $is_slli $is_srli $is_srai $is_add
                  $is_sub $is_sll $is_slt $is_sltu $is_xor $is_srl $is_sra $is_or $is_and $is_load)
            /missing_signals
               $ANY = /cpu_viz/defaults$ANY;
         $ANY = /cpu_viz/missing_signals$ANY;
         `BOGUS_USE($dummy)
      )

// (A copy of this appears in the shell code.)
\TLV sum_prog()
   // /====================\
   // | Sum 1 to 9 Program |
   // \====================/
   //
   // Program to test RV32I
   // Add 1,2,3,...,9 (in that order).
   //
   // Regs:
   //  x12 (a2): 10
   //  x13 (a3): 1..10
   //  x14 (a4): Sum
   // 
   m4_asm(ADDI, x14, x0, 0)             // Initialize sum register x14 with 0
   m4_asm(ADDI, x12, x0, 1010)          // Store count of 10 in register x12.
   m4_asm(ADDI, x13, x0, 1)             // Initialize loop count register x13 with 0
   // Loop:
   m4_asm(ADD, x14, x13, x14)           // Incremental summation
   m4_asm(ADDI, x13, x13, 1)            // Increment loop count by 1
   m4_asm(BLT, x13, x12, 1111111111000) // If x13 is less than x12, branch to label named <loop>
   // Test result value in x14, and set x31 to reflect pass/fail.
   m4_asm(ADDI, x30, x14, 111111010100) // Subtract expected value of 44 to set x30 to 1 if and only iff the result is 45 (1 + 2 + ... + 9).
   m4_asm(BGE, x0, x0, 0) // Done. Jump to itself (infinite loop). (Up to 20-bit signed immediate plus implicit 0 bit (unlike JALR) provides byte address; last immediate bit should also be 0)
   m4_asm_end_tlv()
   m4_define(['M4_MAX_CYC'], 40)


// ^===================================================================^

\SV
   m4_makerchip_module  // (Expanded in Nav-TLV pane.)
\TLV
   // Do nothing.
\SV
   endmodule
