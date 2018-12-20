import QtQuick 2.7
import QtQuick.Window 2.2
//import org.kde.kwin 2.0 as KWin
import org.kde.kwin 2.0 as KWinLib
//import org.kde.kwin 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Plasma

// This is how we get the activity background.
import org.kde.plasma.activityswitcher 1.0 as ActivitySwitcher
import org.kde.activities 0.1 as Activities
//import org.kde.plasma.extras 2.0 as PlasmaExtras

// Let's use some blur!
import QtGraphicalEffects 1.0

import "../code/createClients.js" as CreateClients

//BLAH

	// dashboard background.  Holds window thumbnails.  I hope.
Window {
	id: mainContainer
	visible: true
	height: dashboard.height
	width: dashboard.width
	x: 0
	y: 0
	flags: Qt.WindowTransparentForInput //| Qt.X11BypassWindowManagerHint
	//flags: Qt.X11BypassWindowManagerHint //| Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint // won't work without it, apparently.
	Window {
			id: dashboard
			opacity: 1
			visible: false
			x: 0
			y: dashboard.dockHeight
			color: 'black'
			//flags: Qt.X11BypassWindowManagerHint //| Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint // won't work without it, apparently.
			// Start disabled.  toggleBoth sets this appropriately.
			flags: Qt.ToolTip
			height: 0
			width: 0
			property var windowId: 0
			property var scalingFactor: 1.2
			property var activeScreen: 0
			property int screenWidth: 0
			property int screenHeight: 0
			property var screenRatio: 0
			property int dockHeight: 0

			property var clientsVisible: { new Array }

			function _getDockHeight() {
				// We have to account for any docks.  Which is a hassle, but eh.
				var c;
				var dockHeight = 0;
				for (c = 0; c < workspace.clientList().length; c++) {
					if (workspace.clientList()[c].dock) {
						dockHeight = dockHeight + workspace.clientList()[c].height;
					}
				}
				return dockHeight;
			}

			Item {
				id: mainBackground
				width: dashboard.screenWidth
				anchors.fill: parent
				//focus: true
		    height: dashboard.screenHeight //+ dashboard.dockHeight
				x: 0
				y: -dashboard.dockHeight
				opacity: 1


				// This creates a mouseArea for the rectangle.  We change the height of our dock.
				MouseArea {
					anchors.fill: parent
					enabled: true
					onClicked: {
						mainContainer.toggleBoth();
					}
				}

				// First, we create some states: visible, and otherwise.
				states: [
					State {
						name: 'visible'
					},
					State {
						name: 'invisible'
					}
				]
				NumberAnimation { id: fadeToBlack; running: false; alwaysRunToEnd: true; target: foregroundDarken; property: "opacity"; to: 1; from: 0}
				NumberAnimation { id: fadeFromBlack; running: false; alwaysRunToEnd: true; target: foregroundDarken; property: "opacity"; to: 0; from: 1}
				// These are just temporary to get it out of my way.  We'll change them later.

				ActivitiesContainer {
					// Instantiate our activity container.
					id: allActivities
				}

				Item {
					id: dashboardBackground
					anchors.fill: parent
					height: dashboard.screenHeight - dashboard.dockHeight
					width: dashboard.screenWidth
					property string background: { return allActivities.getCurrentBackground() }
					x: 0
					y: -dashboard.dockHeight
					Image {
						id: firstBackgroundDesktop
						anchors.fill: parent
						smooth: true
						fillMode: Image.PreserveAspectCrop
						source: dashboardBackground.background
						height: dashboard.screenHeight
						width: dashboard.screenWidth
						opacity: 1
						// Maybe?
						asynchronous: true
						cache: false
					}

					Image {
						id: secondBackgroundDesktop
						anchors.fill: parent
						smooth: true
						fillMode: Image.PreserveAspectCrop
						source: dashboardBackground.background
						height: dashboard.screenHeight
						width: dashboard.screenWidth
						opacity: 0
						// Maybe?
						asynchronous: true
						cache: false
					}

					// Doesn't seem to like this.
					FastBlur {
						id: blurBackground
						anchors.fill: secondBackgroundDesktop
						source: secondBackgroundDesktop
						radius: 32
					}

					Rectangle {
						anchors.fill: parent
						id: backgroundDarken
						opacity: 0.5
						color: 'black'
						height: dashboard.screenHeight + dashboard.dockHeight
						width: dashboard.screenWidth
					}
				//}


				Item {
					id: currentDesktopGridThumbnailContainer
					y: dashboard.screenHeight
					visible: false
					height: (dashboard.screenHeight - dashboardDesktopChanger.dash.height - 30) - dashboard.dockHeight
					//y: 15
					states: [
						State {
							name: 'showSearch'
						},
						State {
							name: 'showDesktop'
						}
					]
					// Instantiate the search container.
					Search {
						id: searchFieldAndResults
						// Don't show until we start typing.
						visible: false
						y: dashboardDesktopChanger.dash.height + 30
						height: (dashboard.screenHeight - dashboardDesktopChanger.dash.height - 30 - 15) - dashboard.dockHeight
						width: dashboard.screenWidth
						property int textHeight: 24
						anchors.left: parent.left
					}
					Rectangle {
						//anchors.fill: parent
						id: foregroundDarken
						visible: true
						opacity: 0
						x: 0
						y: 0
						//clip: true
						color: 'black'
						height: dashboard.screenHeight
						width: dashboard.screenWidth
					}
			}
		}
	}

	Timer {
		id: timer
		interval: 200
		//onTriggered: TextField.searchTextChanged()
		onTriggered: {
			// I suspect that we have problems reacquiring focus on a desktop change.
			//dashboard.requestActivate();
			//searchFieldAndResults.children[1].forceActiveFocus();
		}
	}

		function returnNumberOfDesktops() {
			return workspace.desktops;
		}
	}

	Window {
		id: dashboardDesktopChanger
		//opacity: 1
		//flags: Qt.X11BypassWindowManagerHint | Qt.FramelessWindowHint // won't work without it, apparently.
		//flags: Qt.SplashScreen || Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint // won't work without it, apparently.
		//flags: Qt.FramelessWindowHint || Qt.SplashScreen
		//flags: Qt.ToolTip
		//flags: Qt.X11BypassWindowManagerHint
		//flags: Qt.X11BypassWindowManagerHint | Qt.WA_TranslucentBackground | Qt.WindowTransparentForInput | Qt.WA_OpaquePaintEvent | Qt.WA_PaintOnScreen
		flags: Qt.WA_TranslucentBackground | Qt.WA_OpaquePaintEvent | Qt.FramelessWindowHint | Qt.WindowMaximized | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.BypassGraphicsProxyWidget | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
		color: '#00000000'
		visible: true
		title: "Yay"
		//attributes: Qt.WA_TranslucentBackground
		//type: PlasmaCore.Dialog.Dock
		//flags: Qt.WindowStaysOnTopHint
		//location: Qt.application.layoutDirection === Qt.RightToLeft ? PlasmaCore.Types.RightEdge : PlasmaCore.Types.LeftEdge
		x: 0
		//BackgroundHints: 1
		y: 0
		//color: 'black'
		opacity: 1
		//visibility: Window.Fullscreen
		// Start disabled.  toggleBoth sets this appropriately.
		//height: 100 * dashboard.ScalingFactor
		//width: dashboard.screenWidth
		height: (100+20) * dashboard.scalingFactor
		width: 1980
		//height: 1080
		//maximumHeight: (100+20) * dashboard.scalingFactor
		//maximumWidth: 1980
		// Here, we're going to build up the desktops and thumbnails.
		// For each entry here, we want nDesktops in the first row, and one in the second.

		Item {
			id: dash
			//visible: true
			opacity: 1

			// When y is set, we start this animation.  This gracefully moves the dock into position, ignoring the whole 'slide' thing.
			width: dashboard.screenWidth
			//height: main.screenHeight
			height: 100 * dashboard.scalingFactor
			property int gridHeight: 100 * dashboard.scalingFactor
			y: -120 * dashboard.scalingFactor
			//anchors.fill: dashboard.mainBackground
			//anchors.fill: parent

			Rectangle {
				opacity: 0.85
				//visible: dashboard.visible
				visible: true
				height: dash.height + 20
				width: dashboard.screenWidth
				color: '#282828'
			}
			//  This is where wesetWindowFlags(Qt::X11BypassWindowManagerHint)'ll build up the grid.  I like to think, anyway.


			// This seems pretty nice, honestly.
			Flickable {
				id: desktopThumbnailGrid
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.leftMargin: 5
				//anchors.fill: parent

				property int spacing: 10
				height: dash.gridHeight
				contentHeight: desktopThumbnailGridBackgrounds.height
				contentWidth: desktopThumbnailGridBackgrounds.width
				//boundsMovement: Flickable.StopAtBounds
				//boundsBehavior: Flickable.DragAndOvershootBounds

				//visible: true
				//x: 10
				y: 0
				// This is our active rectangle.  We shift it when our active desktop changes.
				Rectangle {
					id: activeDesktopIndicator
					// We just want this to stand out, currently.
					color: 'white'
					opacity: 1
					visible: true
					scale: 1
					clip: true
					//x: -2
					x: ((dash.gridHeight*dashboard.screenRatio+desktopThumbnailGrid.spacing)*(workspace.currentDesktop-1)) - 2
					y: 8
					//height: desktopThumbnailGridBackgrounds.height
					//width: desktopThumbnailGridBackgrounds.width
					height: desktopThumbnailGrid.height+4
					width: (dash.gridHeight*dashboard.screenRatio)+4
				}
				PropertyAnimation {
					id: activeDesktopIndicatorShiftAnim
					target: activeDesktopIndicator
					property: 'x'
					running: false
					property var originalX: 0
					property var newX: 0
					from: activeDesktopIndicatorShiftAnim.originalX
					to: activeDesktopIndicatorShiftAnim.newX
					duration: 1000
					//easing.type: Easing.OutBounce
				}
				Grid {
					// This is just for each of our desktops.
					//id: newRepeater
					id: desktopThumbnailGridBackgrounds
					rows: 1
					x: 0
					y: 10
					spacing: desktopThumbnailGrid.spacing
					//anchors.fill: parent

					columns: {
						if (workspace.desktops <= 6 ) {
							//desktopThumbnailGridBackgrounds.columns = 6;
							return 6;
						} else {
							//desktopThumbnailGridBackgrounds.columns = workspace.desktops;
							return workspace.desktops;
						}
					}
					Repeater {
						// Now, we build up our desktops.
						//model: dashboard.returnNumberOfDesktops()
						model: workspace.desktops
						id: littleDesktopRepeater
						Item {
							id: littleDesktopContainer
							visible: true
							property int desktop: model.index
							height: desktopThumbnailGrid.height
							width: dash.gridHeight*dashboard.screenRatio
							Image {
								id: littleDesktopBackground
								mipmap: true
								fillMode: Image.PreserveAspectCrop
								source: dashboardBackground.background
								height: desktopThumbnailGrid.height
								width: dash.gridHeight*dashboard.screenRatio
								x: 0
								y: 0
							}
								MouseArea {
									id: littleDesktopGridMouseArea
									anchors.fill: parent
									onClicked: {
										// We only want to disable the dashboard when we double click on the item
										// or when we're currently on said desktop and are 'sure'.
										if (littleDesktopContainer.desktop != workspace.currentDesktop-1) {
											workspace.currentDesktop = littleDesktopContainer.desktop+1;
										} else {
												toggleBoth();
										}
									}
								}
							Clients {
								//anchors.fill: parent
								id: littleDesktopGrid
								desktop: littleDesktopContainer.desktop
								//x: dash.gridHeight*.025*dashboard.screenRatio
								//y: dash.gridHeight*.025
								height: dash.gridHeight
								width: dash.gridHeight*dashboard.screenRatio
								//height: dashboard.screenHeight - dash.gridHeight - 30
								//width: dashboard.screenWidth
							}
							// Can we use this?
							DropArea {
								id: littleDesktopDropArea
								//anchors.fill: littleDesktopBackground
								anchors.fill: parent
								x: 0
								y: 0
								height: desktopThumbnailGrid.height
								width: dash.gridHeight*dashboard.screenRatio
								// Doesn't really seem to work.
								/*onDropped: {
									drag.drop.accept();
									console.log('DROPPING!');
									//console.log(drag.source);
									//drag.source.newDesktop = model.index+1;
									//console.log(drag.source.newDesktop);
								}*/
								Rectangle {
									anchors.fill: parent
									visible: false
									color: "green"
								}
								onEntered: {
									console.log('ENTERING!');
									//console.log(Object.getOwnPropertyNames(drag.source));
									drag.source.newDesktop = littleDesktopContainer.desktop+1;
									console.log(drag.source.newDesktop);
								}
								onExited: {
									console.log('LEAVING');
									drag.source.newDesktop = workspace.currentDesktop; //drag.source.currentDesktop;
									console.log(drag.source.newDesktop);
								}
							}
						}
					}
					/*Component.onCompleted: {
						workspace.numberDesktopsChanged.connect(function () {
							littleDesktopRepeater.model = workspace.desktops;
						});
					}*/
				}
			}
			Item {
				id: dashAddRemoveDesktopButtons
				y: 0
				x: dashboard.screenWidth-50
				height: 120
				Rectangle {
					width: 50
					//color: 'black'
					color: 'transparent'
					opacity: 0.5
					LinearGradient {
							anchors.fill: parent
							start: Qt.point(0, 0)
							end: Qt.point(25, 0)
							gradient: Gradient {
									GradientStop { position: 0.0; color: 'transparent' }
									GradientStop { position: 1.0; color: 'black' }
							}
					}
				}
				Rectangle {
					id: plusButton
					//opacity: 0.5
					//visible: dashboard.visible
					height: 55 * dashboard.scalingFactor
					width: 40 * dashboard.scalingFactor
					//color: 'white'
					color: 'transparent'
					Text {
						id: actualPlusButton
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						opacity: 1
						text: "+"
						font.pointSize: 25
						font.bold: true
						color: "white"
						y: 0
					}
					MouseArea {
						anchors.fill: parent
						id: plusButtonMouseArea
						onPressed: {
							console.log('yay');
							actualPlusButton.color = 'grey';
						}
						onReleased: {
							actualPlusButton.color = 'white';
							if (workspace.desktops < 20) {
								workspace.desktops = workspace.desktops + 1;
							}
						}
					}
				}
				Rectangle {
					id: minusButton
					anchors.top: plusButton.bottom
					height: 55 * dashboard.scalingFactor
					width: 40 * dashboard.scalingFactor
					//color: 'white'
					y: 50
					color: 'transparent'
					Text {
						id: actualMinusButton
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						opacity: 1
						text: "-"
						font.pointSize: 25
						font.bold: true
						color: "white"
						y: 0
					}
					MouseArea {
						anchors.fill: parent
						id: minusButtonMouseArea
						onPressed: {
							console.log('yay');
							actualMinusButton.color = 'grey';
						}
						onReleased: {
							actualMinusButton.color = 'white';
							if (workspace.desktops > 1) {
								workspace.desktops = workspace.desktops - 1;
							}
						}
					}
				}
			}
		}
		Component.onCompleted: {
			//dashboard.requestActivate();
			//searchFieldAndResults.children[1].forceActiveFocus();
			populateVisibleClients();

			// disable!

			// Try and register a shortcut, maybe.

			// Make the big ones.
			CreateClients.createAllClientThumbnails(
				currentDesktopGridThumbnailContainer,
				dashboard,
				6,
				dashboard.screenHeight - dash.gridHeight - 30,
				dashboard.screenWidth,
				true
			)
			CreateClients.createAllClientThumbnails(
				desktopThumbnailGrid,
				dashboard,
				6,
				dash.gridHeight*.95,
				dash.gridHeight*dashboard.screenRatio*.95,
				false
			)
			// Make sure we add new thumbnails as necessary.
			workspace.clientAdded.connect(function (c) {
				console.log(c);
				CreateClients.createNewClientThumbnails(
					desktopThumbnailGrid,
					dashboard,
					6,
					dash.gridHeight*.95,
					dash.gridHeight*dashboard.screenRatio*.95,
					false,
					c
				);
				CreateClients.createNewClientThumbnails(
					currentDesktopGridThumbnailContainer,
					dashboard,
					6,
					dashboard.screenHeight - dash.gridHeight - 30,
					dashboard.screenWidth,
					true,
					c
				);
			});
			workspace.currentDesktopChanged.connect(function() {
				activeDesktopIndicatorShiftAnim.newX = ((dash.gridHeight*dashboard.screenRatio+desktopThumbnailGrid.spacing)*(workspace.currentDesktop-1)) - 2;
				activeDesktopIndicatorShiftAnim.originalX = activeDesktopIndicator.x;
				activeDesktopIndicatorShiftAnim.restart();
				if (mainBackground.state == 'visible') {
					//dashboard.requestActivate();
					timer.restart();
				}
			});
		}
		function populateVisibleClients() {
			// We need to build the list.
			var c;
			dashboard.clientsVisible = new Array(workspace.clientList().length);
			for (c = 0; c < workspace.clientList().length; c++) {
				dashboard.clientsVisible[c] = workspace.clientList()[c].minimized;
			}
		}

		function disableVisibleClients() {
			var c;
			for (c = 0; c < workspace.clientList().length; c++) {
				// We're just hiding it by making it invisible.
				workspace.clientList()[c].opacity = 0;
			}
		}
		function enableVisibleClients() {
			var c;
			for (c = 0; c < workspace.clientList().length; c++) {
				if (dashboard.clientsVisible[c] == false) {
					// Better than hiding!
					workspace.clientList()[c].opacity = 1;
				}
			}
		}


	}
	Window {
			id: dashboardActivityChanger
			opacity: 1
			flags: Qt.WA_TranslucentBackground | Qt.WA_OpaquePaintEvent | Qt.FramelessWindowHint | Qt.WindowMaximized | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.BypassGraphicsProxyWidget | Qt.WindowStaysOnTopHint | Qt.X11BypassWindowManagerHint
			color: '#00000000'
			visible: true
			x: 0
			y: dashboard.screenHeight - (100*dashboard.scalingFactor)
			// Start disabled.  toggleBoth sets this appropriately.
			height: 100 * dashboard.scalingFactor
			width: dashboard.screenWidth
			Item {
				id: activitySwitcherDash
				x: 0
				width: dashboard.screenWidth
				//x: screenWidth/2-blahBlahBlah.width
				//y: 124
				//anchors.bottom: mainBackground.bottom
				//y: (dashboard.screenHeight - 80)
				scale: 1
				//y: dashboard.screenHeight
				//y: dashboard.screenHeight - dash.height + 10
				height: 100 * dashboard.scalingFactor
				//y: 90
				y: 100 * dashboard.scalingFactor
				property int gridHeight: 80 * dashboard.scalingFactor
				NumberAnimation {
					id: showActivitySwitcherDashAnim
					running: false
					target: activitySwitcherDash
					property: "y"
					to: dashboard.screenHeight - activitySwitcherDash.height
				}
				NumberAnimation {
					id: hideActivitySwitcherDashAnim
					running: false
					target: activitySwitcherDash
					property: "y"
					to: dashboard.screenHeight - 20
				}
				Timer {
					id: activitySwitcherDashTimer
					interval: 500
					onTriggered: {
						//hideActivitySwitcherDashAnim.restart();
					}
				}
				Rectangle {
					id: activitySwitcherDashBackground
					scale: 1
					opacity: 0.80
					y: 0
					x: 0
					height: activitySwitcherDash.height
					width: dashboard.screenWidth
					color: '#282828'
				}
				MouseArea {
					id: activitySwitcherDashMouseArea
					anchors.fill: parent
					enabled: true
					hoverEnabled: true
					onEntered: {
						//showActivitySwitcherDashAnim.restart();
					}
					onExited: {
						activitySwitcherDashTimer.restart();
					}
				}
				Grid {
					id: activitySwitcherRepeaterGrid
					anchors.fill: parent
					anchors.verticalCenter: parent.verticalCenter
					anchors.horizontalCenter: parent.horizontalCenter
					//anchors.top: activitySwitcherDashBackground.top
					anchors.topMargin: 10 * dashboard.scalingFactor
					anchors.leftMargin: desktopThumbnailGrid.spacing
					rows: 1
					columns:  10
					spacing: desktopThumbnailGrid.spacing
					visible: true
					Repeater {
						id: activitySwitcherRepeater
						model: ActivitySwitcher.Backend.runningActivitiesModel()
						Item {
							x: 0
							y: 0
							visible: true
							height: activitySwitcherDash.gridHeight
							width: activitySwitcherDash.gridHeight*dashboard.screenRatio
							Image {
								id: activityThumbnail
								anchors.fill: parent
								//smooth: true
								mipmap: true
								fillMode: Image.PreserveAspectCrop
								source: model.background
								opacity: 1
								// Maybe?
								asynchronous: true
								cache: false
							}
							Rectangle {
								id: activityThumbnailBlackRectangle
								scale: 1
								opacity: 0
								//y: 0
								//x: 0
								anchors.top: activityThumbnail.top
								//height: 20
								height: activityThumbnail.height
								width: activityThumbnail.width
								color: 'black'
							}
							Text {
								//anchors.fill: parent
								id: activityThumbnailTitleText
								//anchors.top: activityThumbnail.top
								anchors.horizontalCenter: activityThumbnail.horizontalCenter
								anchors.verticalCenter: activityThumbnailBlackRectangle.verticalCenter
								anchors.topMargin: 2
								opacity: 0
								text: model.name
								//font.family: "Helvetica"
								//font.pointSize: 12
								font.bold: true
								color: "white"
								//y: 5
							}
							ParallelAnimation {
								id: thumbnailHoverStart
								running: false
								NumberAnimation {
									target: activityThumbnailBlackRectangle;
									property: 'opacity';
									from: 0;
									to: 0.5;
								}
								NumberAnimation {
									target: activityThumbnailTitleText;
									property: 'opacity';
									from: 0;
									to: 1;
								}
							}
							ParallelAnimation {
								id: thumbnailHoverEnd
								running: false
								PropertyAnimation { target: activityThumbnailBlackRectangle; property: 'opacity'; to: 0; from: 0.5}
								PropertyAnimation { target: activityThumbnailTitleText; property: 'opacity'; to: 0; from: 1}
							}
							MouseArea {
								anchors.fill: parent
								//anchors.fill: activityThumbnail
								//parent: activitySwitcherDashMouseArea
								enabled: true
								hoverEnabled: true
								onClicked: {
									//console.log(Object.getOwnPropertyNames(workspace));
									//console.log(Object.getOwnPropertyNames(ActivitySwitcher));
									//workspace.currentActivity = model.id;
									fadeToBlack.restart();
									ActivitySwitcher.Backend.setCurrentActivity(model.id)
									fadeFromBlack.restart();
								}
								onEntered: {
									//showActivitySwitcherDashAnim.start();
									//hideActivitySwitcherDashAnim.running = false;
									//activitySwitcherDashMouseArea.stop();
									activitySwitcherDashTimer.stop();
									thumbnailHoverStart.restart();
								}
								onExited: {
									//hideActivitySwitcherDashAnim.running = true;
									//activitySwitcherDashMouseArea.stop();
									//activitySwitcherDashTimer.restart();
									thumbnailHoverEnd.restart();
								}
							}
							// In case I ever figure out how to control the activities
							// flag of the clients from here.
							/*DropArea {
								id: activityDropArea
								anchors.fill: parent
								Rectangle {
									anchors.fill: parent
									visible: true
									color: "green"
								}
								onEntered: {
									console.log('ENTERING ACTIVITY!');
									//console.log(Object.getOwnPropertyNames(drag.source));
									//drag.source.newDesktop = bigDesktopRepeater.desktop+1;
									drag.source.newActivity = model.id;
									//console.log(Object.getOwnPropertyNames(ActivitySwitcher.Backend));
									//console.log(Object.getOwnPropertyNames(workspace));
									//con
									//console.log(drag.source.newDesktop);
								}
								onExited: {
									console.log('LEAVING ACTIVITY');
									//drag.source.newDesktop = drag.source.currentDesktop;
									drag.source.newActivity = drag.source.clientObject.activities;
									//console.log(drag.source.newDesktop);
								}
							}*/
						}
					}
				}
			}
		}
		function toggleBoth() {
			console.log('blah');
			console.log(dashboardDesktopChanger.flags)
			console.log(Qt.X11BypassWindowManagerHint)
			if (mainBackground.state == 'visible') {
				endAnim.restart();
				//mainContainer.height = 0
				//mainContainer.width = 0
				//mainContainer.visible = false
				//dashboardDesktopChanger.flags = 1023;
				//dashboardDesktopChanger.flags = Qt.X11BypassWindowManagerHint
				//dashboardDesktopChanger.dashEndAnim.restart();
			} else if (mainBackground.state == 'invisible') {
				//dashboard.flags = Qt.X11BypassWindowManagerHint;
				//dashboard.requestActivate();
				dashboardDesktopChanger.width = dashboard.screenWidth;
				dashboardActivityChanger.width = dashboard.screenWidth;
				//dashboard.height = dashboard.screenHeight;
				//dashboard.width = dashboard.screenWidth;
				mainContainer.height = dashboard.screenHeight;
				mainContainer.width = dashboard.screenWidth;

				initAnim.restart();
				//dashboardDesktopChanger.requestActivate();
				//dashboardDesktopChanger.dashInitAnim.restart();
				mainBackground.state = 'visible';
				mainBackground.visible = true;
				timer.restart();
				//searchFieldAndResults.children[1].forceActiveFocus();
					currentDesktopGrid.itemAt(workspace.currentDesktop-1).children[0].children[c].startMoveToThumbnail();
			}
		}
		ParallelAnimation {
			id: initAnim
			NumberAnimation { target: dash; property: "y"; from: -dash.height*dashboard.scalingFactor; to: 0}
			NumberAnimation { target: activitySwitcherDash; property: "y"; from: (100*dashboard.scalingFactor); to: 0}
			NumberAnimation { target: dashboard; property: "opacity"; to: 1; from: 0}
			// Expensive!
			SequentialAnimation {
				ParallelAnimation {
					NumberAnimation { target: blurBackground; property: "radius"; to: 32; from: 1}
					NumberAnimation { target: backgroundDarken; property: "opacity"; to: 0.5; from: 0}
				}
				NumberAnimation {
					target: dashboard.currentDesktopGridThumbnailContainer
					property: "y"
					to: 15
					from: dashboard.screenHeight
				}
			}
		}
		ParallelAnimation {
			id: endAnim
			SequentialAnimation {
				NumberAnimation {
					target: dashboard.currentDesktopGridThumbnailContainer
					property: "y"
					from: 15
					to: dashboard.screenHeight
					duration: 100
				}
				ParallelAnimation {
					NumberAnimation { target: dashboard; property: "opacity"; to: 0; from: 1; duration: 100}
					NumberAnimation { target: dash; property: "y"; to: -dash.height*dashboard.scalingFactor; duration: 100}
					NumberAnimation { target: activitySwitcherDash; property: "y"; from: 0; to: (100*dashboard.scalingFactor); duration: 100}
					NumberAnimation { target: backgroundDarken; property: "opacity"; to: 0; from: 0.5; duration: 100}
					NumberAnimation { target: blurBackground; property: "radius"; to: 1; from: 32; duration: 100}
					NumberAnimation { target: backgroundDarken; property: "opacity"; from: 0.5; to: 0; duration: 100}
				}
			}

			onRunningChanged: {
				if (!endAnim.running) {
					dashboard.height = 0;
					dashboard.width = 0;
					dashboardDesktopChanger.width = 0;
					dashboardActivityChanger.width = 0;
					mainBackground.state = 'invisible';
					//dashboard.visible = false;
					mainBackground.visible = false;
				}
			}
		}
		Component.onCompleted: {
			//dashboard.requestActivate();
			dashboard.dockHeight = dashboard._getDockHeight();
			dashboard.activeScreen =  workspace.clientArea(KWinLib.MaximizedArea, workspace.activeScreen, workspace.currentDesktop);
			dashboard.screenWidth = dashboard.activeScreen.width;
			dashboard.screenHeight = dashboard.activeScreen.height + dashboard._getDockHeight();
			dashboard.screenRatio = dashboard.activeScreen.width/dashboard.activeScreen.height;
			mainBackground.visible = false;
			mainBackground.state = 'invisible';
			currentDesktopGridThumbnailContainer.state = 'showDesktop';
			console.log('Hey, did it work?');

			// disable!

			// Try and register a shortcut, maybe.
			if (KWin.registerShortcut) {
			KWin.registerShortcut("OVERVIEW: Show kwinOverview",
															"Show kwinOverview",
															"Meta+A",
															function() {
																toggleBoth()
															}
				);
			}
			// Make the big ones.
			height: dashboard.screenHeight - dashboardDesktopChanger.dash.gridHeight - 30
			width: dashboard.screenWidth
		}
}
/*
Repeater {
	// Now, we build up our desktops.
	model: workspace.desktops
	id: currentDesktopGrid
	// We're leaving a little room for the text search area!
	height: (dashboard.screenHeight - dash.height - 30 - 15 - searchFieldAndResults.textHeight) - dashboard.dockHeight
	width: dashboard.screenWidth
	scale: 1
	visible: true
	Item {
		id: bigDesktopRepeater
		visible: true
		property int desktop: model.index
		Clients {
			id: bigDesktopClients
			desktop: bigDesktopRepeater.desktop
			visible: false
			x: 0
			// Leave a little room for the text!
			y: dash.height + 30 + searchFieldAndResults.textHeight - dashboard.dockHeight
			height: (dashboard.screenHeight - dash.height - 30 - activitySwitcherDash.height - 30) - dashboard.dockHeight
			width: dashboard.screenWidth
			isMain: false
			isLarge: true
			DropArea {
				id: bigDesktopDropArea
				anchors.fill: parent
				Rectangle {
					anchors.fill: parent
					visible: false
					color: "green"
				}
				onEntered: {
					console.log('ENTERING LARGE DESKTOP!');
					//console.log(Object.getOwnPropertyNames(drag.source));
					drag.source.newDesktop = bigDesktopRepeater.desktop+1;
					console.log(drag.source.newDesktop);
				}
				onExited: {
					console.log('LEAVING');
					drag.source.newDesktop = drag.source.currentDesktop;
					console.log(drag.source.newDesktop);
				}
			}
		}
	}
}

*/

/*
Component.onCompleted: {
	dashboard.requestActivate();
	searchFieldAndResults.children[1].forceActiveFocus();
	dashboard.dockHeight = _getDockHeight();
	dashboard.activeScreen =  workspace.clientArea(KWinLib.MaximizedArea, workspace.activeScreen, workspace.currentDesktop);
	dashboard.screenWidth = dashboard.activeScreen.width;
	dashboard.screenHeight = dashboard.activeScreen.height + _getDockHeight();
	dashboard.screenRatio = dashboard.activeScreen.width/dashboard.activeScreen.height;
	mainBackground.visible = false;
	mainBackground.state = 'invisible';
	currentDesktopGridThumbnailContainer.state = 'showDesktop';
	populateVisibleClients();

	// disable!

	// Try and register a shortcut, maybe.
	if (KWin.registerShortcut) {
	KWin.registerShortcut("OVERVIEW: Show kwinOverview",
													"Show kwinOverview",
													"Meta+A",
													function() {
														toggleBoth()
													}
		);
	}
	// Make the big ones.
	height: dashboard.screenHeight - dash.gridHeight - 30
	width: dashboard.screenWidth
	CreateClients.createAllClientThumbnails(
		currentDesktopGridThumbnailContainer,
		dashboard,
		6,
		dashboard.screenHeight - dash.gridHeight - 30,
		dashboard.screenWidth,
		true
	)
	CreateClients.createAllClientThumbnails(
		desktopThumbnailGrid,
		dashboard,
		6,
		dash.gridHeight*.95,
		dash.gridHeight*dashboard.screenRatio*.95,
		false
	)
	// Make sure we add new thumbnails as necessary.
	workspace.clientAdded.connect(function (c) {
		console.log(c);
		CreateClients.createNewClientThumbnails(
			desktopThumbnailGrid,
			dashboard,
			6,
			dash.gridHeight*.95,
			dash.gridHeight*dashboard.screenRatio*.95,
			false,
			c
		);
		CreateClients.createNewClientThumbnails(
			currentDesktopGridThumbnailContainer,
			dashboard,
			6,
			dashboard.screenHeight - dash.gridHeight - 30,
			dashboard.screenWidth,
			true,
			c
		);
		dashboard.requestActivate();
		searchFieldAndResults.children[1].forceActiveFocus();
	});
	workspace.currentDesktopChanged.connect(function() {
		activeDesktopIndicatorShiftAnim.newX = ((dash.gridHeight*dashboard.screenRatio+desktopThumbnailGrid.spacing)*(workspace.currentDesktop-1)) - 2;
		activeDesktopIndicatorShiftAnim.originalX = activeDesktopIndicator.x;
		activeDesktopIndicatorShiftAnim.restart();
		if (mainBackground.state == 'visible') {
			dashboard.requestActivate();
			timer.restart();
		}
	});
}
*/
