# Принципы работы тестового окружения (Testbench working principles)

## Оглавление

- [Принципы работы тестового окружения (Testbench working principles)](#принципы-работы-тестового-окружения-testbench-working-principles)
  - [Оглавление](#оглавление)
  - [Назначение документа](#назначение-документа)
  - [Справка](#справка)
  - [Структурная схема тестового окружения](#структурная-схема-тестового-окружения)
  - [Принципы работы тестового окружения](#принципы-работы-тестового-окружения)
    - [Модуль alu\_matrix\_tb\_top](#модуль-alu_matrix_tb_top)
    - [Класс alu\_matrix\_test](#класс-alu_matrix_test)
    - [Класс alu\_matrix\_env](#класс-alu_matrix_env)
    - [Класс alu\_matrix\_reg\_model](#класс-alu_matrix_reg_model)
    - [Класс alu\_matrix\_scoreboard](#класс-alu_matrix_scoreboard)
    - [Классы агентов clk\_agent, rst\_agent, irq\_agent, apb\_master\_agent, axi\_stream\_master\_agent и axi\_stream\_slave\_agent](#классы-агентов-clk_agent-rst_agent-irq_agent-apb_master_agent-axi_stream_master_agent-и-axi_stream_slave_agent)
    - [Классы драйверов clk\_driver, rst\_driver, apb\_master\_driver, axi\_stream\_master\_driver и axi\_stream\_slave\_driver](#классы-драйверов-clk_driver-rst_driver-apb_master_driver-axi_stream_master_driver-и-axi_stream_slave_driver)
    - [Классы мониторов rst\_monitor, irq\_monitor, apb\_master\_monitor, axi\_stream\_monitor](#классы-мониторов-rst_monitor-irq_monitor-apb_master_monitor-axi_stream_monitor)
    - [Графическое изображение запускающихся потоков](#графическое-изображение-запускающихся-потоков)

## Назначение документа

Документ описывает принципы работы тестового окружения для блока АЛУ для операций над матрицами (ALU_MATRIX).


## Справка

Изучение данного документа подразумевается после ознакомления с материалом [описания тестового окружения](./testbench_description.md).

Также необходимо знать конструкции [fork..join](https://www.chipverify.com/systemverilog/systemverilog-fork-join), [fork..join_any](https://www.chipverify.com/systemverilog/systemverilog-fork-join-any), [fork..join_none](https://www.chipverify.com/systemverilog/systemverilog-fork-join-none).


## Структурная схема тестового окружения

Для удобства - [иерархия файлов](./methodics_and_guides.md#навигация-по-проекту) и схема:

![](./img/Env_desc.svg "Структурная схема тестового окружения")

## Принципы работы тестового окружения

В данном разделе разобраны принципы работы всего тестового окружения, начиная с самого верхнего уровня.

### Модуль alu_matrix_tb_top

Модуль `alu_matrix_tb_top` является верхним уровнем всего проекта. В нем содержатся всего четыре сущности: интерфейс окружения (`alu_matrix_env_if env_if`), окружение (`alu_matrix_env env`), тест (`alu_matrix_test test`) и проверяемый дизайн (`ymp_alu_matrix_top alu_matrix`).

Обратите внимание, что перед объявлением самого топового модуля указаны включения четырех файлов проекта через ``` `include```. Это необходимо для успешной сборки проекта перед симуляцией.

DUT уже подключен к окружению через интерфейс `enf_if`. При запуске симуляции выполняется код внутри блока `initial begin..end`: устанавливается формат вывода времени с помощью [$timeformat](https://www.chipverify.com/verilog/verilog-timeformat), создаются объекты классов окружения и теста, а затем вызывается функция запуска теста `run()`:

```SystemVerilog
initial begin
  // Set time format
  $timeformat(-12, 0, " ps", 10);

  // Creating environment
  env = new(env_if);

  // Creating test
  test = new(env);

  // Calling run of test
  test.run();
end
```

---

### Класс alu_matrix_test

Класс `alu_matrix_test` должен содержать в себе сценарии генерации входных стимулов (воздействий) на проверяемый дизайн. Внутри уже есть код, необходимый для правильной работы CI, который **нельзя** редактировать. **Он обрамлен комментариями, содержащими слова "DO NOT TOUCH CODE".**

Класс содержит переменную класса окружения `env`, с использованием которой должно осуществляться любое взаимодействие теста с окружением. Например, чтобы считать значение периода тактового сигнала из класса `clk_driver`, достаточно написать:
```SystemVerilog
int your_int_var = env.clk_agent.driver.period;
```

Также класс содержит API, необходимый для быстрой разработки тестов. API включает в себя следующие таски:

| Название                                                                                         | Описание
| ------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ```clk_transaction_put(int t_period)```                                                          | создает clk транзакцию с полем `period`, равному аргументу, и отправляет в соответствующий mailbox;                                                       |
| ```rst_transaction_put(int t_duration)```                                                        | создает rst транзакцию с полем `duration`, равному аргументу, и отправляет в соответствующий mailbox;                                                     |
| ```apb_transaction_put(logic [`APB_ADDR_W -1:0] t_addr = 0, t_data = 0, logic t_is_write = 0)``` | создает APB транзакцию с: `addr`, равным `t_addr`; `is_write`, равным `t_is_write`; `data`, равным `t_data`; и отправляет в соответствующий mailbox;      |
| ```axis_transaction_put(logic signed [`AXI_DATA_W -1:0] t_data[$])```                            | создает AXI-stream транзакцию с полем `data`, равным `t_data` и отправляет в соответствующий mailbox;                                                     |
| ```wait_apb_end_trans()```                                                                       | выполнение данного таска завершится с окончанием APB транзакции на интерфейсе apb_if;                                                                     |
| ```wait_axis_in_end_trans()```                                                                   | выполнение данного таска завершится с окончанием AXI-stream транзакции на интерфейсе axis_in_if;                                                          |
| ```wait_axis_out_end_trans()```                                                                  | выполнение данного таска завершится с окончанием AXI-stream транзакции на интерфейсе axis_out_if.                                                         |


После вызова из `alu_matrix_tb_top` начинает выполняться таск (task) `run()`, внутри которого с помощью `fork..join_none` запускается четыре ***параллельных*** потока: два сервисных, один с запуском работы окружения и один пользовательский (с генерацией и передачей в драйверы агентов транзакций). Сервисные потоки необходимы для завершения симуляции в случаях: 1) слишком долгой симуляции (время симуляции превысило определенное значение), в этом случае симуляция завершится с выводом сообщения `"SIMULATION TIME EXCEEDED! Exiting..."`; 2) по достижению максимального допустимого количества ошибок, в этом случае симуляция завершится с выводом сообщения `"MAXIMUM ERROR COUNT REACHED! Exiting..."`. Поток с запуском окружения, очевидно, необходим для работы всех верификационных компонентов. Пользовательский поток **обязан** завершаться вызовом `finish()`.

В таске `main()` в пользовательском потоке описан выбор теста на исполнение с помощью конструкции `case..endcase`. В случае ввода в скрипте `run.sh` или в строке запуска (о ней можно узнать [здесь](./methodics_and_guides.md#запуск)) неверного имени теста (который не описан в `case`) симуляция завершится с выводом сообщения `"UNDEFINED TESTNAME WAS SET! Exiting..."`. Если же имя теста при запуске не будет указано вовсе, то симуляция завершится с выводом сообщения `"TESTNAME WAS NOT SET! Exiting..."`.

В качестве примера изначально предоставлен пример теста под названием `TEST_BASIC`, который вызывает таск `basic_test()`:

```SystemVerilog
// Example basic test
task basic_test();
  // Start generating clock signal with period of 10 ns
  clk_transaction_put(10);
  // Wait for the first posedge clk
  @(posedge env.vif.clk_if.clk);
  // Drive active reset for 50 ns
  rst_transaction_put(50);
  // Set some values in registers using APB
  apb_transaction_put(32'h10, 3, 1);
  wait_apb_end_trans();
  apb_transaction_put(32'h14, 3, 1);
  wait_apb_end_trans();
  apb_transaction_put(32'h00, 3, 1);
  wait_apb_end_trans();
  // Drive matrix using AXI-stream
  matrix = {1,2,3,4,5,6,7,8,9};
  axis_transaction_put(matrix);
  wait_axis_in_end_trans();
  // Check ISR, write 1 to clear it
  // and then collect result or repeat
  // ...
endtask
```
В таске `basic_test()` совершается следующая последовательность действий:

| Номер действия | Код                                | Описание
| -------------- | ---------------------------------- | ---------------------------------------------------------------------------------------------- |
| 1              | clk_transaction_put(10)            | передача в clk драйвер clk транзакции для старта генерации тактового сигнала с периодом 10 нс; |
| 2              | @(posedge env.vif.clk_if.clk)      | ожидание первого posedge clk                                                                   |
| 3              | rst_transaction_put(50)            | передача в rst драйвер rst транзакции для генерации сброса длительностью 50 нс;                |
| 4              | apb_transaction_put(32'h10, 3, 1); | передача в APB драйвер APB транзакции для записи в регистр MATRIX0V (адрес - 0x10) числа 3;    |
| 5              | wait_apb_end_trans();              | ожидание окончания APB транзакции;                                                             |
| 6              | apb_transaction_put(32'h14, 3, 1); | передача в APB драйвер APB транзакции для записи в регистр MATRIX0H (адрес - 0x14) числа 3;    |
| 7              | wait_apb_end_trans();              | ожидание окончания APB транзакции;                                                             |
| 8              | apb_transaction_put(32'h00, 3, 1); | передача в APB драйвер APB транзакции для записи в регистр OPCODE (адрес - 0x00) числа 3;      |
| 9              | wait_apb_end_trans();              | ожидание окончания APB транзакции;                                                             |
| 10             | matrix = {1,2,3,4,5,6,7,8,9};      | заполнение матрицы числами от 1 до 9                                                           |
| 11             | axis_transaction_put(matrix);      | передача в AXI-stream драйвер ведущего агента AXI-stream транзакции для передачи матрицы;      |
| 12             | wait_axis_in_end_trans();          | ожидание окончания AXI-stream транзакции;                                                      |

---

### Класс alu_matrix_env

Класс является описанием окружения, включающего в себя все остальные верификационные подкомпоненты: регистровую модель, агенты и скорборд.

При вызове функции `new()` (из `alu_matrix_tb_top`) локальной переменной интерфейса окружения присваивается полученный дескриптор интерфейса окружения и последовательно вызывается создание регистровой модели, mailbox-ов и всех остальных верификационных подкомпонентов с передачей им аргументов - интерфейсов агентов, mailbox-ов и одного event.

```SystemVerilog
// Constructor
function new(virtual alu_matrix_env_if vif);

  this.vif                 = vif;

  // Creating registers model
  this.alu_matrix_regs     = new();

  // Creating mailboxes
  this.rst2scrb            = new();
  this.in2scrb             = new();
  this.out2scrb            = new();
  this.apb2scrb            = new();
  this.irq2scrb            = new();

  // Creating agents
  this.clk_agent           = new(vif.clk_if                         );
  this.rst_agent           = new(vif.rst_if,      rst2scrb          );

  this.axis_master_agent   = new(vif.axis_in_if,  in2scrb,  first_hs);
  this.axis_slave_agent    = new(vif.axis_out_if, out2scrb          );
  this.apb_master_agent    = new(vif.apb_if,      apb2scrb          );

  this.irq_agent           = new(vif.irq_if,      irq2scrb          );

  // Creating scoreboard
  this.scrb                = new(alu_matrix_regs, rst2scrb, in2scrb, out2scrb, apb2scrb, irq2scrb, first_hs);

endfunction
```

После вызова из `alu_matrix_tb_top` начинает выполняться таск `run()`, который последовательно запускает таск `pre_main()` и таск `main()`. Таск `pre_main()` предназначен для выполнения предварительных действий. Внутри таска `main()` с помощью `fork..join_none` запускается семь ***параллельных*** потоков - каждый запускает работу определенного верификационного подкомпонента:

```SystemVerilog
task main();
  fork
    clk_agent.run();
    rst_agent.run();

    axis_master_agent.run();
    axis_slave_agent.run();
    apb_master_agent.run();

    irq_agent.run();

    scrb.run();
  join_none
endtask
```

---

### Класс alu_matrix_reg_model

Класс `alu_matrix_reg_model` состоит из набора регистров, названия и размеры которых совпадают с названиями и размерами конфигурационных регистров АЛУ, взятых из [спецификации](./dut_specification.md).

Также есть две функции:
1. `reset()`, вызов которой приведет к обнулению всех регистров.
2. `update (apb_master_transaction coll_apb_transaction)`, вызов которой записывает значение `coll_apb_transaction.data` в нужный регистр, опираясь на его адрес `coll_apb_transaction.addr`.

---

### Класс alu_matrix_scoreboard

Класс является контейнером для описаний всех типов проверок, совершаемых в процессе симуляции.

Внутри уже есть код, необходимый для правильной работы CI, который **нельзя** редактировать. **Он обрамлен комментариями, содержащими слова "DO NOT TOUCH CODE".**

Также класс уже содержит переменные регистровой модели, mailbox-ов и одного event, дескрипторы которым присваиваются в процессе выполнения функции `new()`. Использование содержимого пакета [(package)](https://www.chipverify.com/systemverilog/systemverilog-package) `alu_matrix_pkg`, содержащего определения перечисляемых типов [(enum)](https://www.chipverify.com/systemverilog/systemverilog-enumeration) для состояний APB и AXI-stream драйверов, а также для кодов операций АЛУ в соответствии со спецификацией, обеспечено импортом всего его содержимого непосредственно перед объявлением класса:

```SystemVerilog
import alu_matrix_pkg::*;
```

Из класса окружения скорборд запускается вызовом таска `run()`, который последовательно запускает функцию `pre_main()` и таск `main()`. Функция `pre_main()` предназначена для выполнения предварительных действий в нулевой момент времени симуляции. Таск `main()` предназначен для сбора транзакций с mailbox-ов и выполнения всех проверок.

В качестве примера в скорборде изначально предоставлены **неполные** последовательности обработки APB и reset транзакций. В таске `main()` параллельно выполняются два потока, ограниченных конструкциями `forever begin..end`: один для reset транзакций, а второй для APB транзакций. По получению reset транзакции `coll_rst_transaction` из соответствующего mailbox (`rst2scrb`) происходит обнуление всех регистров регистровой модели с помощью вызова функции `reset()`. По получению APB транзакции `coll_apb_transaction` из соответствующего mailbox (`apb2scrb`) создается ее копия `coll_apb_transaction_clone`, которая передается в качестве аргумента в функцию обновления значения регистровой модели `update(coll_apb_transaction_clone)`, а оригинальная транзакция передается в качестве аргумента в функцию обработки APB транзакций `process_apb_transaction(coll_apb_transaction)`. Клонирование транзакции приведено в качестве примера решения проблемы, когда необходимо изменять/читать значения полей любого объекта из разных мест (например, из двух различных функций). Т.к. в SystemVerilog передача в функцию аргумента означает передачу дескриптора объекта, то при изменении свойств объекта в одном месте, это свойство изменится и в другом. Если коротко, то происходит передача ссылки на объект, а не его копирование.

Дополнительно к вышеописанному скорборд содержит пустые прототипы тасков для обработки APB и AXI-stream транзакций (`process_apb_transaction(...)`, `process_axis_in_transaction(...)` и `process_axis_out_transaction(...)`).

### Классы агентов clk_agent, rst_agent, irq_agent, apb_master_agent, axi_stream_master_agent и axi_stream_slave_agent

Классы являются контейнерами для верификационных подкомпонентов: драйвера и монитора. Наличие того или иного подкомпонента определяется конфигурацией агента. **В данном проекте агенты уже сконфигурированы необходимым для выполнения задания Хакатона образом.** Один агент отвечает только за свой интерфейс.

При вызове функции `new()` (из `alu_matrix_env`) последовательно вызывается создание mailbox-а драйвера (при его наличии), драйвера (при его наличии) и монитора (при его наличии) с передачей им аргументов - интерфейсов агентов, mailbox-ов и одного event.

Например, функция `new()` в APB агенте:
```SystemVerilog
function new(virtual apb_master_agent_if apb_if, mailbox mon_outside);
    to_driver = new();

    driver    = new(apb_if, to_driver);
    monitor   = new(apb_if, mon_outside);
endfunction
```

После вызова из `alu_matrix_env` начинает выполняться таск `run()`, который последовательно запускает функцию `pre_main()` и таск `main()`. Функция `pre_main()` предназначена для выполнения предварительных действий в нулевой момент времени симуляции. Внутри таска `main()` с помощью `fork..join_none` запускаются ***параллельные*** потоки - каждый запускает работу определенного верификационного подкомпонента: драйвера или монитора.

Например, таск `main()` в APB агенте:
```SystemVerilog
task main();
  fork
    monitor.run();
    driver.run();
  join_none
endtask
```

---

### Классы драйверов clk_driver, rst_driver, apb_master_driver, axi_stream_master_driver и axi_stream_slave_driver

Классы являются активными верификационными подкомпонентами, переводящими объекты транзакций в последовательные изменения сигналов интерфейсов в соответствии с протоколом обмена.

При вызове функции `new()` (из соответствующего драйверу агента) локальному mailbox-у (при его наличии) присваивается полученный в виде аргумента дескриптор mailbox-а из агента, а локальной переменной интерфейса - дескриптор интерфейса.

Например, функция `new()` в APB драйвере:
```SystemVerilog
function new(virtual apb_master_agent_if apb_if, mailbox to_driver);
  this.to_driver = to_driver;
  this.vif       = apb_if;
endfunction
```

После вызова из соответствующего драйверу агента начинает выполняться таск `run()`, который последовательно запускает функцию `pre_main()` и таск `main()`. Функция `pre_main()` предназначена для выполнения предварительных действий в нулевой момент времени симуляции. Внутри таска `main()` в бесконечном цикле `forever begin..end` ожидается установка сигнала `rst_n` из `X` в `0` или `1` (только в драйверах APB и AXI-stream подобных интерфейсов), а затем происходит ожидание попадание в mailbox транзакции, получив которую драйвер начинает манипулировать сигналами. Затем цикл повторяется.

В драйверах APB и AXI-stream подобных интерфейсов: 1) ожидание попадание в mailbox транзакции и ее исполнение находится в одном из ***параллельных*** потоков, созданных с помощью `fork..join_any`. Во втором потоке происходит ожидание активации сброса, в случае которого работа драйвера тоже сбрасывается; 2) непосредственно манипулирование сигналов вынесено в таск `drive_transaction()`. Исключением является драйвер `axi_stream_slave_driver`, который во время сброса выставляет низкий уровень сигнала `axis_ready`, а вне сброса всегда держит высокий уровень.

Например, таск `main()` в APB драйвере:
```SystemVerilog
task main();
  forever begin
    wait(!$isunknown(vif.rst_n));
    fork
      begin
        @(posedge vif.rst_n);
        forever begin
          to_driver.get(transaction);
          if ($test$plusargs("TRAN_INFO")) begin
            transaction.display("[apb_master_driver]");
          end
          drive_transaction(transaction);
        end
      end
      begin
        @(negedge vif.rst_n);
        vif.paddr   <= 0;
        vif.pwrite  <= 0;
        vif.pwdata  <= 0;
        vif.penable <= 0;
      end
    join_any
    disable fork;
  end
endtask
```

**`ВАЖНО: нельзя подавать транзакцию rst в rst драйвер в нулевой момент времени!`**

---

### Классы мониторов rst_monitor, irq_monitor, apb_master_monitor, axi_stream_monitor

Классы являются пассивными верификационными подкомпонентами, переводящими последовательные изменения сигналов интерфейсов в объекты транзакций в соответствии с протоколом обмена.

При вызове функции `new()` (из соответствующего монитору агента) локальному mailbox-у присваивается полученный в виде аргумента дескриптор mailbox-а из агента (который получил его в виде аргумента из окружения), а локальной переменной интерфейса - дескриптор интерфейса.

Например, функция `new()` в APB мониторе:
```SystemVerilog
function new(virtual apb_master_agent_if apb_if, mailbox mon_outside);
  this.vif             = apb_if;
  this.mon_outside     = mon_outside;

  this.wait_cycles_max = 50;
endfunction
```

После вызова из соответствующего монитору агента начинает выполняться таск `run()`, который последовательно запускает функцию `pre_main()` и таск `main()`. Функция `pre_main()` предназначена для выполнения предварительных действий в нулевой момент времени симуляции. Внутри таска `main()` в бесконечном цикле `forever begin..end` ожидается установка сигнала `rst_n` из `X` в `0` или `1` (кроме `irq_monitor`, который ожидает установки сигнала `irq` в `0` или `1`), а затем происходит отслеживание на шине изменения сигналов в соответствии с протоколом и формируется транзакция с наблюдаемыми данными, которая затем кладется в mailbox. Затем цикл повторяется.

В мониторах APB и AXI-stream подобных интерфейсов: 1) отслеживание на шине изменения сигналов в соответствии с протоколом и формирование транзакции с наблюдаемыми данными находится в одном из ***параллельных*** потоков, созданных с помощью `fork..join_any`. Во втором потоке происходит ожидание активации сброса, в случае которого переменной класса транзакции присваивается дескриптор `null` (ссылка в "никуда"), чтобы после дизактивации сброса монитор начинал заполнять данными новую пустую транзакцию; 2) непосредственно отслеживание изменения сигналов вынесено в таск `monitor_transaction()`.

Например, таск `main()` в APB мониторе:
```SystemVerilog
task main();
  forever begin
    wait(!$isunknown(vif.rst_n));
    @(posedge vif.rst_n);
    fork
      begin
        forever begin
          monitor_transaction();
          if ($test$plusargs("TRAN_INFO")) begin
            transaction.display("[apb_master_monitor]");
          end
          mon_outside.put(transaction);
          transaction = null;
        end
      end
      begin
        @(negedge vif.rst_n);
        transaction = null;
      end
    join_any
    disable fork;
  end
endtask
```

---

### Графическое изображение запускающихся потоков

Ниже находится графическое изображение запускающихся потоков.

Обратите внимание, что названия условные.

Красным цветом выделены потоки, возможность создать которые предоставляется ВАМ.

![](./img/tb_threads.svg "Графическое изображение запускающихся потоков")
