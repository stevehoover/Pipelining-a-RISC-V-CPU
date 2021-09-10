\m4_TLV_version 1d: tl-x.org
\SV
   // This code can be found in: https://github.com/stevehoover/LF-Building-a-RISC-V-CPU-Core/risc-v_shell.tlv
   
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/Pipelining-a-RISC-V-CPU/main/lib/risc-v_shell_lib.tlv'])
   m4_include_lib(['https://raw.githubusercontent.com/stevehoover/tlv_lib/master/fundamentals_lib.tlv'])
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
// Register File
\TLV rf(_entries, _width, $_reset, $_port1_en, $_port1_index, $_port1_data, $_port2_en, $_port2_index, $_port2_data, $_port3_en, $_port3_index, $_port3_data)
   $rf1_wr_en = m4_argn(4, $@);
   $rf1_wr_index[\$clog2(_entries)-1:0]  = m4_argn(5, $@);
   $rf1_wr_data[_width-1:0] = m4_argn(6, $@);
   
   $rf1_rd_en1 = m4_argn(7, $@);
   $rf1_rd_index1[\$clog2(_entries)-1:0] = m4_argn(8, $@);
   
   $rf1_rd_en2 = m4_argn(10, $@);
   $rf1_rd_index2[\$clog2(_entries)-1:0] = m4_argn(11, $@);
   
   /xreg[m4_eval(_entries-1):0]
      $wr = |cpu$rf1_wr_en && (|cpu$rf1_wr_index == #xreg);
      <<1$value[_width-1:0] = |cpu$_reset ? #xreg              :
                                 $wr      ? |cpu$rf1_wr_data :
                                            $RETAIN;
   
   $_port2_data[_width-1:0]  =  $rf1_rd_en1 ? /xreg[$rf1_rd_index1]$value : 'X;
   $_port3_data[_width-1:0]  =  $rf1_rd_en2 ? /xreg[$rf1_rd_index2]$value : 'X;
   
   /xreg[m4_eval(_entries-1):0]
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
            
            let rd = (rf_rd_en1.asBool(false) && rf_rd_index1.asInt() == this.getIndex()) || 
                     (rf_rd_en2.asBool(false) && rf_rd_index2.asInt() == this.getIndex())
            
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
         
\TLV tb()
   $passed_cond = (/xreg[30]$value == 32'b1) &&
                  (! $reset && $next_pc[31:0] == $pc[31:0]);
   *passed = >>2$passed_cond;

// Data Memory
\TLV dmem(_entries, _width, $_reset, $_addr, $_port1_en, $_port1_data, $_port2_en, $_port2_data)
   // Allow expressions for most inputs, so define input signals.
   $dmem1_wr_en = $_port1_en;
   $dmem1_addr[\$clog2(_entries)-1:0] = $_addr;
   $dmem1_wr_data[_width-1:0] = $_port1_data;
   
   $dmem1_rd_en = $_port2_en;
   
   /dmem[m4_eval(_entries-1):0]
      $wr = |cpu$dmem1_wr_en && (|cpu$dmem1_addr == #dmem);
      <<1$value[_width-1:0] = |cpu$_reset ? 0                 :
                              $wr         ? |cpu$dmem1_wr_data :
                                            $RETAIN;
   
   $_port2_data[_width-1:0] = $dmem1_rd_en ? /dmem[$dmem1_addr]$value : 'X;
   /dmem[m4_eval(_entries-1):0]
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
                     let instrs = ["lui", "auipc", "jal", "jalr", "beq", "bne", "blt", "bge", "bltu", "bgeu", "lb", "lh", "lw", "lbu", "lhu", "sb", "sh", "sw", "addi", "slti", "sltiu", "xori", "ori", "andi", "slli", "srli", "srai", "add", "sub", "sll", "slt", "sltu", "xor", "srl", "sra", "or", "and", "csrrw", "csrrs", "csrrc", "csrrwi", "csrrsi", "csrrci", "load", "s_instr"];
                     for(i=0;i<instrs.length;i++) {
                        var sig = this.svSigRef(`CPU_is_${instrs[i]}_a0`)
                        if(sig != null && sig.asBool()) {
                           return instrs[i].toUpperCase()
                        }
                     }
                     return "ILLEGAL"
                  }
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
   
                  if (instr != sticky_zero) {
                     this.getInitObjects().imem_box.setVisible(true)
                     this.getInitObjects().imem_header.setVisible(true)
                     this.getInitObjects().decode_box.setVisible(true)
                     this.getInitObjects().decode_header.setVisible(true)
                  }
                  let pcPointer = new fabric.Text("👉", {
                     top: M4_IMEM_TOP + 18 * (pc.asInt() / 4),
                     left: -375,
                     fill: "blue",
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
                              fill: "blue",
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
                     fill: "blue",
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
                     fill: "black",
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
                     fill: "blue",
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
                     fill: "blue",
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
                     fill: "blue",
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
                     fill: "blue",
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
                     fill: "blue",
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
                     let reset = this.svSigRef(`CPU_reset_a0`)
                     let pc = this.svSigRef(`CPU_pc_a0`)
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
   
         // Provide missing signals.
         /viz_defaults
            {m4_sigs_list} = '0;
            `BOGUS_USE(m4_bogus_sigs_list)
         /missing_signals
            $ANY = |cpu/viz_defaults$ANY;
         $ANY = /missing_signals$ANY;
         `BOGUS_USE($dummy)
      )
\SV
   m4_makerchip_module   // (Expanded in Nav-TLV pane.)
   /* verilator lint_on WIDTH */
\TLV
   m4+sum_prog()
   |cpu
      @0
         $reset = *reset;

         $start = >>1$reset && ! $reset;
         $valid = ! $reset && ($start || >>3$valid);


         $next_pc[31:0] = $reset ? 32'b0 :
                          >>2$valid_taken_br ? >>2$br_tgt_pc :
                          >>2$is_jal ? >>2$br_tgt_pc :
                          >>2$is_jalr ? >>2$jalr_tgt_pc :
                          >>2$pc + 32'd4;
         $pc[31:0] = >>1$next_pc;

         `READONLY_MEM($pc, $$instr[31:0])

         $is_u_instr = $instr[6:2] ==? 5'b0x101;
         $is_i_instr = $instr[6:2] ==? 5'b0000x ||
                       $instr[6:2] ==? 5'b001x0 ||
                       $instr[6:2] ==? 5'b11001;
         $is_r_instr = $instr[6:2] ==? 5'b01011 ||
                       $instr[6:2] ==? 5'b011x0 ||
                       $instr[6:2] ==? 5'b10100;
         $is_s_instr = $instr[6:2] ==? 5'b0100x;
         $is_b_instr = $instr[6:2] ==? 5'b11000;
         $is_j_instr = $instr[6:2] ==? 5'b11011;

         $funct7[6:0] = $instr[31:25];
         $rs2[4:0]    = $instr[24:20];
         $rs1[4:0]    = $instr[19:15];
         $funct3[2:0] = $instr[14:12];
         $rd[4:0]     = $instr[11:7];
         $opcode[6:0] = $instr[6:0];

         $funct7_valid = $is_r_instr;
         $rs2_valid    = $is_r_instr || $is_s_instr || $is_b_instr;
         $rs1_valid    = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         $funct3_valid = $is_r_instr || $is_i_instr || $is_s_instr || $is_b_instr;
         $rd_valid     = $is_r_instr || $is_i_instr || $is_u_instr || $is_j_instr;
         $imm_valid    = $is_i_instr || $is_s_instr || $is_b_instr || $is_u_instr || $is_j_instr;

         $imm[31:0] = $is_i_instr ? {  {21{$instr[31]}},  $instr[30:20]  } :
                      $is_s_instr ? {  {21{$instr[31]}},  $instr[30:25],  $instr[11:7]  } :
                      $is_b_instr ? {  {20{$instr[31]}},  $instr[7],  $instr[30:25],  $instr[11:8], 1'b0  } :
                      $is_u_instr ? {  $instr[31:12],  12'b0  } :
                      $is_j_instr ? {  {12{$instr[31]}},  $instr[19:12], $instr[20],  $instr[30:21],  1'b0  } :
                                    32'b0;

         `BOGUS_USE($funct7 $funct7_valid $rs2 $rs2_valid $rs1 $rs1_valid
                    $funct3 $funct3_valid $rd $rd_valid $imm $imm_valid $opcode)

         $dec_bits[10:0] = {$funct7[5],$funct3,$opcode};

         /*
         $is_lui   = $dec_bits ==? 11'bx_xxx_0110111;
         $is_auipc = $dec_bits ==? 11'bx_xxx_0010111;
         */
         $is_jal   = $dec_bits ==? 11'bx_xxx_1101111;
         $is_jalr  = $dec_bits ==? 11'bx_xxx_1100111;
         /*
         $is_beq   = $dec_bits ==? 11'bx_000_1100011;
         $is_bne   = $dec_bits ==? 11'bx_001_1100011;
         */
         $is_blt   = $dec_bits ==? 11'bx_100_1100011;
         $is_bge   = $dec_bits ==? 11'bx_101_1100011;
         /*
         $is_bltu  = $dec_bits ==? 11'bx_110_1100011;
         $is_bgeu  = $dec_bits ==? 11'bx_111_1100011;
         */
         $is_addi  = $dec_bits ==? 11'bx_000_0010011;
         /*
         $is_slti  = $dec_bits ==? 11'bx_010_0010011;
         $is_sltiu = $dec_bits ==? 11'bx_011_0010011;
         $is_xori  = $dec_bits ==? 11'bx_100_0010011;
         $is_ori   = $dec_bits ==? 11'bx_110_0010011;
         $is_andi  = $dec_bits ==? 11'bx_111_0010011;
         $is_slli  = $dec_bits ==? 11'b0_001_0010011;
         $is_srli  = $dec_bits ==? 11'b0_101_0010011;
         $is_srai  = $dec_bits ==? 11'b1_101_0010011;
         */
         $is_add   = $dec_bits ==? 11'b0_000_0110011;
         /*
         $is_sub   = $dec_bits ==? 11'b1_000_0110011;
         $is_sll   = $dec_bits ==? 11'b0_001_0110011;
         $is_slt   = $dec_bits ==? 11'b0_010_0110011;
         $is_sltu  = $dec_bits ==? 11'b0_011_0110011;
         $is_xor   = $dec_bits ==? 11'b0_100_0110011;
         $is_srl   = $dec_bits ==? 11'b0_101_0110011;
         $is_sra   = $dec_bits ==? 11'b1_101_0110011;
         $is_or    = $dec_bits ==? 11'b0_110_0110011;
         $is_and   = $dec_bits ==? 11'b0_111_0110011;
         */

         $is_load  = $opcode == 7'b0000011;

         //`BOGUS_USE($is_beq $is_bne $is_blt $is_bge $is_bltu $is_bgeu $is_addi $is_add)

         /*
         // SLTU and SLTI (set if less than, unsigned) results:
         $sltu_rslt[31:0]  = {31'b0, $src1_value < $src2_value};
         $sltiu_rslt[31:0] = {31'b0, $src1_value < $imm};

         // SRA and SRAI (shift right, arithmetic) results:
         //   64-bit sign-extended src1
         $sext_src1[63:0] = { {32{$src1_value[31]}}, $src1_value };
         //   64-bit sign-extended results, to be truncated
         $sra_rslt[63:0] = $sext_src1 >> $src2_value[4:0];
         $srai_rslt[63:0] = $sext_src1 >> $imm[4:0];
         */

         $result[31:0] =
             /*
             $is_andi  ?  $src1_value & $imm                        :
             $is_ori   ?  $src1_value | $imm                        :
             $is_xori  ?  $src1_value ^ $imm                        :
             (/-* $is_addi || *-/ $is_load || $is_s_instr)  ?  $src1_value + $imm                        :
             $is_slli  ?  $src1_value << $imm[5:0]                  :
             $is_srli  ?  $src1_value >> $imm[5:0]                  :
             $is_and   ?  $src1_value & $src2_value                 :
             $is_or    ?  $src1_value | $src2_value                 :
             $is_xor   ?  $src1_value ^ $src2_value                 :
             */
             $is_addi  ?  $src1_value + $imm                        :
             $is_add   ?  $src1_value + $src2_value                 :
             /*
             $is_sub   ?  $src1_value - $src2_value                 :
             $is_sll   ?  $src1_value << $src2_value[4:0]           :
             $is_srl   ?  $src1_value >> $src2_value[4:0]           :
             $is_sltu  ?  $sltu_rslt                                :
             $is_sltiu ?  $sltiu_rslt                               :
             $is_lui   ?  {$imm[31:12], 12'b0}                      :
             $is_auipc ?  $pc + $imm                                :
             $is_jal   ?  $pc + 4                                   :
             $is_jalr  ?  $pc + 4                                   :
             $is_slt   ?  ( ($src1_value[31] == $src2_value[31]) ?
                                $sltu_rslt :
                                {31'b0, $src1_value[31]} )          :
             $is_slti  ?  ( ($src1_value[31] == $imm[31]) ?
                                $sltiu_rslt :
                                {31'b0, $src1_value[31]} )          :
             $is_sra   ?  $sra_rslt[31:0]                           :
             $is_srai  ?  $srai_rslt[31:0]                          :
             */
                          32'b0;

         $taken_br =
             //$is_beq  ? $src1_value == $src2_value :
             //$is_bne  ? $src1_value != $src2_value :
             $is_blt  ? ($src1_value <  $src2_value) ^ ($src1_value[31] != $src2_value[31]) :
             $is_bge  ? ($src1_value >= $src2_value) ^ ($src1_value[31] != $src2_value[31]) :
             //$is_bltu ? $src1_value <  $src2_value :
             //$is_bgeu ? $src1_value >= $src2_value :
                        1'b0;
         $valid_taken_br = $valid && $taken_br;

         $br_tgt_pc[31:0] = $pc + $imm;

         $jalr_tgt_pc[31:0] = $src1_value + $imm;


         // Assert these to end simulation (before Makerchip cycle limit).
         m4+tb()
         *failed = *cyc_cnt > M4_MAX_CYC;

         m4+rf(32, 32, $reset, $rd_valid && ($rd != 0) && $valid, $rd, $is_load ? $ld_data : $result, $rs1_valid, $rs1, $src1_value, $rs2_valid, $rs2, $src2_value)
         m4+dmem(32, 32, $reset, $result[6:2], $is_s_instr, $src2_value[31:0], $is_load, $ld_data)
         m4+cpu_viz(1)  // cpu_viz(show_viz_in_diagram)
\SV
   endmodule