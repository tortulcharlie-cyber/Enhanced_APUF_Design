# BCH Error Correction
2 print("\nApplying BCH Error Correction...")
3 # Define BCH parameters (e.g., (15, 7, 1)
code: 15 bits total, 7 data, 8 parity,
corrects 1 error)
4 n = 15 # Codeword length
5 k = 7 # Data length (bits per segment)
6 t = 1 # Number of correctable errors
7
8 # Initialize BCH field and encoder/decoder
9 GF = galois.GF(2**4) # GF(2ˆ4) for (15, 7,
1) BCH
10 bch = galois.BCH(n, k, t)
11
12 # Segment processed_responses into k-bit
groups (padding if necessary)
13 num_segments = (num_samples + k - 1) // k #
Ceiling division
14 segmented_responses =
np.array(processed_responses[:num_segments
* k]).reshape(-1, k)
15
16 # Apply BCH encoding and simulate noise for
each segment
17 corrected_responses = []
18 for segment in segmented_responses:
19 # Pad segment to n bits with zeros
20 encoded = bch.encode(np.pad(segment, (0,
n - k), mode=’constant’))
21
22 # Simulate noise (10% chance of 1 error)
23 if np.random.random() < 0.1:
24 error_pos = np.random.randint(0, n)
25 encoded[error_pos] = 1 -
encoded[error_pos]
26
27 # Decode to correct errors
28 decoded = bch.decode(encoded)
29 corrected_responses.extend(decoded[:k])
# Take k bits per segment
30
31 # Truncate to original length if padded
32 corrected_responses =
corrected_responses[:num_samples]
33
34 # Save corrected CRPs to a new CSV
35 with open(’puf_corrected_crps.csv’, ’w’,
newline=’’) as csvfile:
36 writer = csv.writer(csvfile)
37 writer.writerow([’challenge’,
’corrected_response’])
38 for challenge, response in
zip(challenges, corrected_responses):
39 writer.writerow([hex(challenge),
response])
40
41 print(f"Saved {num_samples} corrected
challenge-response pairs to
’puf_corrected_crps.csv’")
