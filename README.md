# Toll Plaza Traffic Management and Payment Gateway System

<!-- First Section -->
## Team Details
<details>
  <summary>Detail</summary>
  
> Semester: 3rd Sem B. Tech. CSE

> Section: S1

> Team ID: S1-T11

> Member 1: Amulya Paathipati Kolar, 231CS111,  amulyapaathipatikolar.231cs111@nitk.edu.in

> Member 2: Preeti Mondal, 231CS144, preetimondal.231cs144@nitk.edu.in

> Member 3: Vanshika Mittal, 231CS163, vanshikamittal.231cs163@nitk.edu.in
</details>

<!-- Second Section -->
## Abstract
<details>
  <summary>Detail</summary>
  
  ### Motivation: 
  Toll plazas often become chaotic due to vehicles switching lanes to save time, and the mix of Fastag and cash users creates additional congestion. While Fastag systems aim to speed up toll collection, cash payments in Fastag lanes slow traffic. Toll facilities help reduce congestion and improve mobility, and provide an additional source of funding for local construction and maintenance projects. Hence, we aimed to create a more streamlined system that satisfies the mentioned functions.
  
  ### Problem Statement:
  We propose to make a system that reduces toll plaza congestion by segregating vehicles based on Fastag validity, weight, and payment method, while providing dedicated lanes for VIP and emergency vehicles. This system will streamline traffic flow, ensure efficient toll collection, and prioritize immediate passage for high-priority vehicles. Fastag users will experience a faster process with balance and payment checks, while non-Fastag users will be directed to cash lanes, minimizing overall delays.
  
  ### Features:
  1. Separate Lane for VIP and Emergency Vehicles: These vehicles will have a dedicated lane for immediate passage.
  2. General Vehicle Check for Fastag Validity: All general vehicles will be checked for a valid Fastag account (using Luhn’s Algorithm).
     - Vehicles with Fastag will be segregated into lanes based on their weight.
     - Vehicles without Fastag will be directed to a cash counter.
  3. Balance Check and Payment Authentication: At the toll gate, the system will check the Fastag balance:
     - If balance is sufficient, payment is authenticated and a green light will indicate that the vehicle can pass.
     - If balance is insufficient or payment fails, a red light will indicate the vehicle is not allowed to pass.
 
</details>

## Functional Block Diagram
<details>
  <summary>Detail</summary>
  
![S1-T11 drawio](https://github.com/user-attachments/assets/a72f91d2-8ab6-482d-8920-6cf7948c18bd)

</details>

<!-- Third Section -->
## Working
<details>
  <summary>Detail</summary>

  > Explain the working of your model with the help of a functional table (compulsory) followed by the flowchart.
</details>

<!-- Fourth Section -->
## Logisim Circuit Diagram
<details>
  <summary>Detail</summary>

  > Update a neat logisim circuit diagram
</details>

<!-- Fifth Section -->
## Verilog Code
<details>
  <summary>Detail</summary>

  > Neatly update the Verilog code in code style only.
</details>

## References
<details>
  <summary>Detail</summary>
  
  > National Payments Corporation of India. _Evolution and Innovations in the Tolling Industry._<br/>
  > (https://www.npci.org.in/PDF/npci/knowledge-center/partner-whitepapers/Evolution-and-Innovations-in-the-Tolling-Industry.pdf)

  > Aeologic Technologies. _How RFID Solutions are Changing Toll Collection Systems._ <br/>
  > (https://www.linkedin.com/pulse/how-rfid-solutions-changing-toll-collection-systems-xf1nc/)

  > GeeksforGeeks. _Luhn algorithm._ <br/>
  > (https://www.geeksforgeeks.org/luhn-algorithm/)
  
</details>
