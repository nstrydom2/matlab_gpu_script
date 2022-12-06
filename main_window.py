#!/usr/bin/python
import sys
from pathlib import Path

from PySide6.QtCore import QDateTime, QThreadPool, QRunnable
from PySide6.QtGui import Qt, QPixmap
from PySide6.QtWidgets import QVBoxLayout, QPushButton, QMainWindow, QLabel, QHBoxLayout, \
    QApplication, QLineEdit, QWidget, QStatusBar, QCalendarWidget, QDateEdit, QFileDialog, QCheckBox, QFormLayout, \
    QGroupBox

from config import varz
from util import scan


class MainWindow(QMainWindow):
    def __init__(self):
        super(MainWindow, self).__init__()

        self.initUI()

    def init_var(self):
        self.output_file = ''

    def initUI(self):
        self.init_var()

        output_layout = QHBoxLayout()
        self.body_layout = QVBoxLayout()
        gran_layout = QHBoxLayout()
        prices_layout = QHBoxLayout()

        title = QLabel('Matlab GPU Hyperparameter Scanner v0.1.1')
        # title.setMargin(12)
        font = title.font()
        font.setPointSize(12)
        title.setFont(font)
        title.setStyleSheet('font-weight: bold; color: #00540b;')
        title.setAlignment(Qt.AlignHCenter | Qt.AlignVCenter)
        self.body_layout.addWidget(title)

        self.var_group_box = QGroupBox("Variables")
        self.jj_line = QLineEdit()
        self.st_line = QLineEdit()
        self.fin2_line = QLineEdit()
        self.stf_line = QLineEdit()
        self.finf_line = QLineEdit()
        self.low_line = QLineEdit()
        self.high_line = QLineEdit()
        self.gsfact1_line = QLineEdit()
        self.dgs_line = QLineEdit()
        self.dcy_line = QLineEdit()
        self.dd_line = QLineEdit()
        self.dlr_line = QLineEdit()
        self.l2_line = QLineEdit()
        self.cycles_st_line = QLineEdit()
        self.cycles_fin_line = QLineEdit()
        self.cycles_delta_line = QLineEdit()
        self.days_st_line = QLineEdit()
        self.days_fin_line = QLineEdit()
        self.days_delta_line = QLineEdit()
        self.cells_st_line = QLineEdit()
        self.cells_fin_line = QLineEdit()
        self.cells_delta_line = QLineEdit()
        self.lrate_st_line = QLineEdit()
        self.lrate_fin_line = QLineEdit()
        self.lrate_delta = QLineEdit()
        self.gsfact_st_line = QLineEdit()
        self.gsfact_fin_line = QLineEdit()
        self.gsfact_delta_line = QLineEdit()
        self.n_gpus_line = QLineEdit()

        layout = QFormLayout()
        layout.addRow(QLabel("jj"), self.jj_line)
        layout.addRow(QLabel("st"), self.st_line)
        layout.addRow(QLabel("fin2"), self.fin2_line)
        layout.addRow(QLabel("stf"), self.stf_line)
        layout.addRow(QLabel("finf"), self.finf_line)
        layout.addRow(QLabel("low"), self.low_line)
        layout.addRow(QLabel("high"), self.high_line)
        layout.addRow(QLabel("gsfact1"), self.gsfact1_line)
        layout.addRow(QLabel("dgs"), self.dgs_line)
        layout.addRow(QLabel("dcy"), self.dcy_line)
        layout.addRow(QLabel("dd"), self.dd_line)
        layout.addRow(QLabel("dlr"), self.dlr_line)
        layout.addRow(QLabel("l2"), self.l2_line)
        layout.addRow(QLabel("cycles_st"), self.cycles_st_line)
        layout.addRow(QLabel("cycles_fin"), self.cycles_fin_line)
        layout.addRow(QLabel("cycles_delta"), self.cycles_delta_line)
        layout.addRow(QLabel("days_st"), self.days_st_line)
        layout.addRow(QLabel("days_fin"), self.days_fin_line)
        layout.addRow(QLabel("days_delta"), self.days_delta_line)
        layout.addRow(QLabel("cells_st"), self.cells_st_line)
        layout.addRow(QLabel("cells_fin"), self.cells_fin_line)
        layout.addRow(QLabel("cells_delta"), self.cells_delta_line)
        layout.addRow(QLabel("lrate_st"), self.lrate_st_line)
        layout.addRow(QLabel("lrate_fin"), self.lrate_fin_line)
        layout.addRow(QLabel("lrate_delta"), self.lrate_delta )
        layout.addRow(QLabel("gsfact_st"), self.gsfact_st_line)
        layout.addRow(QLabel("gsfact_fin"), self.gsfact_fin_line)
        layout.addRow(QLabel("gsfact_delta"), self.gsfact_delta_line)
        layout.addRow(QLabel("n_gpus"), self.n_gpus_line)
        self.var_group_box.setLayout(layout)

        self.output_path_box = QLineEdit()
        layout.addRow(QLabel("Output Path"), self.output_path_box)
        self.body_layout.addWidget(self.var_group_box)

        # self.name_box = QLineEdit()
        # self.body_layout.addWidget(QLabel("Output Path"))
        # output_layout.addWidget(self.name_box)
        # self.file_button = QPushButton('...')
        # self.file_button.clicked.connect(self.on_export_button_clicked)
        # output_layout.addWidget(self.file_button)
        # self.body_layout.addLayout(output_layout)

        self.button1 = QPushButton("Start")
        self.button1.move(10, 20)
        self.button1.clicked.connect(self.run_click)
        self.body_layout.addWidget(self.button1)

        button2 = QPushButton("Quit")
        button2.move(10, 20)
        button2.clicked.connect(self.quit_click)
        self.body_layout.addWidget(button2)
        self.body_layout.setAlignment(Qt.AlignTop)

        self.status_bar = QStatusBar()
        self.status_bar.setFixedHeight(25)

        self.icon_label = QLabel()
        #self.status_icon = QPixmap(r'C:\Users\Steve\Desktop\forex\nick\production\trafficlight-red_40428.ico')
        #self.icon_label.setPixmap(self.status_icon.scaledToHeight(self.status_bar.height() / 2))
        self.status_bar.setStyleSheet('QStatusBar::item {border: None;}')
        self.status_bar.addPermanentWidget(QLabel(' Ready '))
        self.status_bar.addPermanentWidget(self.icon_label)
        self.setStatusBar(self.status_bar)

        w = QWidget()
        w.setLayout(self.body_layout)

        self.w1 = None
        self.setCentralWidget(w)
        #self.setFixedHeight(400)
        self.setFixedWidth(380)
        self.setWindowTitle('MGHS v0.1.1')
        self.setFocus()

    def on_export_button_clicked(self):
        filename, filter = QFileDialog.getSaveFileName(parent=self, caption='Select output file', dir='.',
                                                       filter='XLSX Files (*.xlsx)')

        if filename:
            if '.xlsx' not in filename:
                filename += '.xlsx'
        self.output_file = filename
        self.name_box.setText(filename)

    def set_ready_status(self):
        self.status_bar = QStatusBar()
        self.status_bar.setFixedHeight(25)

        #self.status_bar.setStyleSheet('QStatusBar::item {border: None;}')
        self.status_bar.addPermanentWidget(QLabel(' Ready '))
        self.setStatusBar(self.status_bar)

    def set_busy_status(self):
        self.status_bar = QStatusBar()
        self.status_bar.setFixedHeight(25)

        #self.status_bar.setStyleSheet('QStatusBar::item {border: None;}')
        self.status_bar.addPermanentWidget(QLabel(' Busy '))
        self.setStatusBar(self.status_bar)

    def run_program(self):
        # pool = QThreadPool.globalInstance()
        # main_worker = Worker(self.save)
        #
        # pool.start(main_worker)
        self.run_scanner()

    def enable_widgets(self):
        self.name_box.setEnabled(True)
        self.file_button.setEnabled(True)

        self.dateedit_start.setEnabled(True)
        self.dateedit_end.setEnabled(True)

        self.bids_chkbox.setEnabled(True)
        self.asks_chkbox.setEnabled(True)
        self.mids_chkbox.setEnabled(True)

        self.onemin_chkbox.setEnabled(True)
        self.tenmin_chkbox.setEnabled(True)
        self.thirtymin_chkbox.setEnabled(True)
        self.oneday_chkbox.setEnabled(True)

        self.button1.setEnabled(True)

    def disable_widgets(self):
        self.name_box.setDisabled(True)
        self.file_button.setDisabled(True)

        self.dateedit_start.setDisabled(True)
        self.dateedit_end.setDisabled(True)

        self.bids_chkbox.setDisabled(True)
        self.asks_chkbox.setDisabled(True)
        self.mids_chkbox.setDisabled(True)

        self.onemin_chkbox.setDisabled(True)
        self.tenmin_chkbox.setDisabled(True)
        self.thirtymin_chkbox.setDisabled(True)
        self.oneday_chkbox.setDisabled(True)

        self.button1.setDisabled(True)

    def run_scanner(self):
        self.disable_widgets()
        self.set_busy_status()

        try:
            jj = self.jj_line.text()
            st = self.st_line.text()
            fin2 = self.fin2_line.text()
            stf = self.stf_line.text()
            finf = self.finf_line.text()
            low = self.low_line.text()
            high = self.high_line.text()
            gsfact1 = self.gsfact1_line.text()
            dgs = self.dgs_line.text()
            dcy = self.dcy_line.text()
            dd = self.dd_line.text()
            dlr = self.dlr_line.text()
            l2 = self.l2_line.text()
            cycles_st = self.cycles_st_line.text()
            cycles_fin = self.cycles_fin_line.text()
            cycles_delta = self.cycles_delta_line.text()
            days_st = self.days_st_line.text()
            days_fin = self.days_fin_line.text()
            days_delta = self.days_delta_line.text()
            cells_st = self.cells_st_line.text()
            cells_fin = self.cells_fin_line.text()
            cells_delta = self.cells_delta_line.text()
            lrate_st = self.lrate_st_line.text()
            lrate_fin = self.lrate_fin_line.text()
            lrate_delta = self.lrate_delta.text()
            gsfact_st = self.gsfact_st_line.text()
            gsfact_fin = self.gsfact_fin_line.text()
            gsfact_delta = self.gsfact_delta_line.text()
            output_path = self.output_path_box.text()
            n_qpus = self.n_gpus_line.text()

            scan(output_path, jj, st, fin2, stf, finf, low, high, gsfact1, dgs, dcy, dd, dlr, l2, cycles_st,
                 cycles_fin, cycles_delta, days_st, days_fin, days_delta, cells_st, cells_fin, cells_delta,
                 lrate_st, lrate_fin, lrate_delta, gsfact_st, gsfact_fin, gsfact_delta, n_gpus)
        except Exception as ex:
            print(f'[!] ERROR -- {ex}')
        finally:
            self.set_ready_status()
            self.enable_widgets()

    def run_click(self):
        self.run_program()

    def quit_click(self):
        self.close()


def main():
    def gui_start():
        app = QApplication(sys.argv)
        ex = MainWindow()
        ex.show()
        sys.exit(app.exec())

    # bot_thread = threading.Thread(target=bot_start)
    # bot_thread.start()
    gui_start()
