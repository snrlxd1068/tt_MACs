import math

def to_q2_26(float_val):
    # Scale by 2^26
    scaled = round(float_val * (2**26))
    
    # Clamp to signed 28-bit range
    return max(-2**27, min(2**27-1, scaled))

def generate_fixed_point_lut(filename = "log_lut2.mem"):
    lut_data = []
    with open(filename,"w") as f:

        d_start = 0.5
        d_step = 1
        d_max = 20
        num_steps = int((d_max - d_start) / d_step) + 1
        
        

        print(f"{'i':<5} | {'d':<6} | {'Float':<15} | {'Q2.26 (Dec)':<12} | {'Hex'}")
        print("-" * 50)

        for i in range(num_steps):
            d = d_start + (i * d_step)
            val = math.log2(1 + pow(2, -d))
            q_val = to_q2_26(val)
            
            lut_data.append(q_val)
            
            # Display sample rows
            if i < 50 or i > num_steps - 6:
                # Format as hex, ensuring 4 digits for 16-bit
                hex_val = f"{q_val & 0xFFFFFFF:07X}"
                print(f"{i:<5} | {d:<6.2f} | {val:.10f} | {q_val:<12} | {hex_val}")
                f.write(f"{hex_val} // index {i}: d={d}; val={val}\n")

        d_start = 0.5
        d_step = 1
        d_max = 20
        num_steps = int((d_max - d_start) / d_step) + 1

        for i in range(num_steps):
            d = d_start + (i * d_step)
            val = math.log2(1 - pow(2, -d))
            q_val = to_q2_26(val)
            
            lut_data.append(q_val)
            
            # Display sample rows
            if i < 50 or i > num_steps - 6:
                # Format as hex, ensuring 4 digits for 16-bit
                hex_val = f"{q_val & 0xFFFFFFF:06X}"
                print(f"{i:<5} | {d:<6.2f} | {val:.10f} | {q_val:<12} | {hex_val}")
                f.write(f"{hex_val} // index {i}: d={d}; val={val}\n")

    return lut_data

# Generate the table
q_lut = generate_fixed_point_lut()