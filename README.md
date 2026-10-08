# VHDL Digital Stopwatch (MM:SS) on Basys 3 FPGA

**[TR]** Digilent Basys 3 FPGA kartı üzerinde 4 haneli 7-segment gösterge kullanılarak tasarlanmış, buton kontrollü (Başlat/Durdur/Sıfırla) ve FSM filtreli (Debounce) dijital kronometre projesi.  
**[EN]** A 4-digit digital stopwatch (MM:SS) implemented in VHDL on the Digilent Basys 3 FPGA board, featuring FSM-based button debouncing, cascaded BCD counters, and display time-multiplexing.

---

##  Özellikler / Features

| Parametre / Parameter | Değer / Value | Açıklama (TR) | Description (EN) |
| :--- | :--- | :--- | :--- |
| **Target Board** | Digilent Basys 3 |
| **Clock Input** | 100 MHz | Dahili sistem osilatörü | On-board system oscillator |
| **Display Format** | `MM:SS` (00:00 - 59:59) | 4 Hane Ortak Anot 7-Segment | 4-Digit Common Anode 7-Segment |
| **Controls** | `START` & `RST` | Başlat/Durdur (Toggle) ve Sıfırla | Start/Pause toggle and Reset |

---

## Sistem Mimarisi / System Architecture

**[TR]** 
1. **Debounce Filtresi (`debounce.vhd`):** `START` ve `RST` butonlarından gelen mekanik sıçramalar ve metastabilite, 2 kademeli senkronizör ve FSM zamanlayıcısı ile filtrelenir.
2. **Kademeli BCD Sayıcılar (`bcd_incrementor.vhd`):**
   * **Saniye Sayacı:** 00'dan 59'a kadar sayar; 59'dan 00'a geçerken 1 saat vuruşluk elde (`carry_o`) üretir.
   * **Dakika Sayacı:** Saniyenin ürettiği elde sinyalini dinleyerek 00'dan 59'a kadar artar.
3. **Zaman Çoğullama (Time-Multiplexing):** 4 hane 1 ms aralıklarla sırayla taranarak insan gözünün algılayamayacağı 250 Hz hızında sürekli ve net bir görüntü oluşturulur.
4. **Zaman Ayırıcı Nokta (`dp`):** Dakika ile saniye arasındaki nokta saniyede bir yanıp sönerek çalışmayı gösterir.

**[EN]**
1. **Button Debouncer (`debounce.vhd`):** Eliminates mechanical bounces and metastability from `START` and `RST` inputs using an FSM and a 2-stage synchronizer.
2. **Cascaded BCD Counters (`bcd_incrementor.vhd`):**
   * **Seconds Counter:** Counts 00 to 59; generates a 1-clock-cycle carry pulse (`carry_o`) on rollover.
   * **Minutes Counter:** Triggered strictly by the seconds carry pulse, counting 00 to 59.
3. **Display Time-Multiplexing:** The 4 digits are scanned sequentially every 1 ms (overall refresh rate of 250 Hz), providing a smooth, flicker-free display.
4. **Blinking Decimal Point (`dp`):** Acts as a visual seconds indicator (1s ON, 1s OFF) between minutes and seconds.

---

## Simülasyon Doğrulaması / Simulation Verification

Tasarım Vivado Simulator kullanılarak iki aşamada doğrulanmıştır: Alt seviye BCD sayıcı birim testi ve tam sistem entegrasyon testi.  
*(The design was verified in two stages using Vivado Simulator: Sub-module BCD unit testing and full-system integration testing).*

---

### 1. BCD Sayıcı Birim Testi / BCD Incrementor Unit Test (`tb_bcd_incrementor.vhd`)
**[TR]** Sayıcının 00'dan 59'a kadar sayması, `increment_i = '0'` iken duraklaması (Pause), `rst_i = '1'` anında anında sıfırlanması ve 59'dan 00'a geçerken tam 1 saat vuruşluk elde (`carry_o`) darbesi üretmesi doğrulanmıştır.  
**[EN]** Verification of the 2-digit BCD counter: Counting 00 to 59, pausing on enable deassertion, synchronous reset behavior, and generating a strictly 1-clock-cycle carry pulse (`carry_o`) on rollover.

<img width="2560" height="395" alt="image" src="https://github.com/user-attachments/assets/292c920f-ef35-41cf-93dd-922722b9bed8" />

---

### 2. Sistem Entegrasyon Testi / Top-Level System Integration (`tb_top.vhd`)
Hızlı simülasyon amacıyla saat frekansı `c_clkfreq = 1` olarak ayarlanmış ve tüm sistem uçtan uca simüle edilmiştir.  
*(Simulated with scaled clock frequency `c_clkfreq = 1` for fast end-to-end verification).*

**[TR]** Saniye birler ve saniye onlar hanelerinin periyodik olarak düzenli bir şekilde 00'dan 59'a doğru aktığı gözlemlenmiştir. Saniye sayacı her `59`dan `00`a döndüğü anda, saniyenin ürettiği taşma darbesi dakika sayacını tam zamanında tetiklemiş ve dakika hanesi `0`dan `1`e geçmiştir.  
**[EN]** Observation of normal second increments across ones (0-9) and tens (0-5) digits. Every time the seconds counter rolls over from `59` to `00`, the generated carry pulse advances the minute digit from `0` to `1` (`00:59` ➔ `01:00`).

<img width="2560" height="238" alt="image" src="https://github.com/user-attachments/assets/dc587284-4e07-48e6-9ca1-10b20b08c1b2" />

---

<img width="2560" height="247" alt="image" src="https://github.com/user-attachments/assets/73e8c3a2-308b-4d61-86c6-e97401ab6bff" />

---

## Donanım Doğrulaması (FPGA Demo) / Hardware Verification

**[TR]** Tasarım Basys 3 kartına yüklenmiş; buton ile başlatma, durdurma, devam etme ve sıfırlama fonksiyonları ile gösterge kararlılığı fiziksel donanım üzerinde başarıyla doğrulanmıştır.  
**[EN]** Implemented on the physical Basys 3 FPGA board; Start, Pause, Resume, and Reset operations as well as display multiplexing stability are verified on hardware.

[stopwatch.webm](https://github.com/user-attachments/assets/36ee09bb-823c-4e31-9f48-cdfd558d9c84)

---

## Dosya Yapısı / Project Structure

```text
├── constrs_1/
│   └── Basys-3-Master.xdc    # FPGA pin bağlantıları / Constraints file
├── sim_1/
│   ├── tb_bcd_incrementor.vhd# BCD sayıcı birim testi / BCD unit test
│   └── tb_top.vhd            # Sistem entegrasyon testbench'i / Top testbench
├── sources_1/
│   ├── bcd_incrementor.vhd   # 2 haneli BCD sayıcı modülü / BCD counter core
│   ├── bcd_to_sevenseg.vhd   # 7-Segment kod çözücü / 7-Segment decoder
│   ├── debounce.vhd          # Buton filtre modülü / Button debouncer
│   └── top.vhd               # Ana entegrasyon modülü / Top-level module
└── README.md                 # Proje dokümantasyonu / Project documentation
