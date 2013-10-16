/****************************************************************
**
** Microphone App
**
****************************************************************/
#include <QtGui/QApplication>
#include <qapplication.h>
#include <qpushbutton.h>
#include <qshortcut.h>
#include <qmenu.h>
#include <QLabel>

int main(int argc, char **argv)
{
    QApplication a(argc, argv);

    /*
    QPushButton hello("Leopold!", 0);
    hello.resize(100, 30);
	hello.show();
    */

    QImage statusImg;
    statusImg.load("Done/done.png");

    QLabel myLabel("Status", 0);
    myLabel.setPixmap(QPixmap::fromImage(statusImg));
    myLabel.resize(100, 30);
    myLabel.show();


    /*
	QShortcut *shortcut = new QShortcut(QKeySequence("Ctrl+O"), parent);
	QObject::connect(shortcut, SIGNAL(activated()), receiver, SLOT(yourSlotHere()));
	*/

	/*	
	QMenu * editMenu = new QMenu;
	QAction * copyItem = editMenu->addAction("Copy", hello, SLOT(CopyData()));
	copyItem->setShortcut("Ctrl+C");
	*/

    return a.exec();
}
