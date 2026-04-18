import math

def to_q6_18(float_val):
    # Scale by 2^18
    scaled = round(float_val * (2**18))
    
    # Clamp to signed 24-bit range (-32768 to 32767)
    return max(-2**23, min(2**23-1, scaled))

def generate_fixed_point_lut(filename = "log_lut.mem"):
    lut_data = []
    with open(filename,"w") as f:

        d_start = 0.25
        d_step = 0.5
        d_max = 20
        num_steps = int((d_max - d_start) / d_step) + 1
        
        

        print(f"{'i':<5} | {'d':<6} | {'Float':<15} | {'Q6.10 (Dec)':<12} | {'Hex'}")
        print("-" * 50)

        for i in range(num_steps):
            d = d_start + (i * d_step)
            val = math.log2(1 + pow(2, -d))
            q_val = to_q6_18(val)
            
            lut_data.append(q_val)
            
            # Display sample rows
            if i < 50 or i > num_steps - 6:
                # Format as hex, ensuring 4 digits for 16-bit
                hex_val = f"{q_val & 0xFFFFFF:06X}"
                print(f"{i:<5} | {d:<6.2f} | {val:.10f} | {q_val:<12} | {hex_val}")
                f.write(f"{hex_val} // index {i}: d={d}\n")

        d_start = 0.25
        d_step = 0.5
        d_max = 20
        num_steps = int((d_max - d_start) / d_step) + 1

        for i in range(num_steps):
            d = d_start + (i * d_step)
            val = math.log2(1 - pow(2, -d))
            q_val = to_q6_18(val)
            
            lut_data.append(q_val)
            
            # Display sample rows
            if i < 50 or i > num_steps - 6:
                # Format as hex, ensuring 4 digits for 16-bit
                hex_val = f"{q_val & 0xFFFFFF:06X}"
                print(f"{i:<5} | {d:<6.2f} | {val:.10f} | {q_val:<12} | {hex_val}")
                f.write(f"{hex_val} // index {i}: d={d}\n")

    return lut_data

# Generate the table
q_lut = generate_fixed_point_lut()