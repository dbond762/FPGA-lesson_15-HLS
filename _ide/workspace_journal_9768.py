# 2026-10-18T19:51:59.886647400
import vitis

client = vitis.create_client()
client.set_workspace(path="HW_15")

comp = client.create_hls_component(name = "hls_component",part = "xc7z020clg400-1",cfg_file = ["hls_config.cfg"],template = "empty_hls_component")

cfg = client.get_config_file(path="D:\FPGA\HW_10_2\HW_15\hls_component\hls_config.cfg")

cfg.set_values(key="syn.file", values=["moving_max.cpp"])

cfg.set_values(key="syn.file", values=["moving_max.cpp", "moving_max.h"])

cfg = client.get_config_file(path="/d:/FPGA/HW_10_2/HW_15/hls_component/hls_config.cfg")

cfg.set_value(section="hls", key="syn.top", value="moving_max")

vitis.dispose()

