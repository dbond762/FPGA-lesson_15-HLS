# 2026-10-18T19:56:44.625252800
import vitis

client = vitis.create_client()
client.set_workspace(path="HW_15")

cfg = client.get_config_file(path="/d:/FPGA/HW_15/hls_component/hls_config.cfg")

cfg.set_value(section="hls", key="syn.compile.pipeline_loops", value="0")

cfg = client.get_config_file(path="D:\FPGA\HW_15\hls_component\hls_config.cfg")

cfg.set_values(key="tb.file", values=["tb_moving_max.cpp"])

comp = client.get_component(name="hls_component")
comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

comp.run(operation="C_SIMULATION")

comp.run(operation="SYNTHESIS")

