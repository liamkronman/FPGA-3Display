NUM_ROWS = 64
RGB_RES = 9
# NUM_ROWS = 6
# RGB_RES = 1
NUM_COLS = NUM_ROWS
SCAN_RATE = NUM_ROWS//2
RADIUS = SCAN_RATE
CENTER_Y = SCAN_RATE

def access_index(dut, col_idx, row):
    # :params:
    # dut: cocotb handle
    # col_idx: int, column index (0 or 1)
    # row: int, row index
    # :return:
    # int, RGB_RES-wide value cast to int

    # dut.columns is RGB_RES x NUM_ROWS x 2 array
    value = 0
    for i in range(RGB_RES):
        value += dut.columns[(col_idx * NUM_ROWS + row) * RGB_RES + i].value << i
    return value