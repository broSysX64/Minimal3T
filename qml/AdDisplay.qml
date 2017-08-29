/*
 * Copyright (c) 2017 Alex Spataru <alex_spataru@outlook.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import QtQuick 2.0
import QtPurchasing 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2

import com.dreamdev.QtAdMobBanner 1.0
import com.dreamdev.QtAdMobInterstitial 1.0

Item {
    property bool adsEnabled: false
    property bool removeAdsBought: false

    //
    // Locates the banner on the bottom of the screen
    //
    function displayBanner() {
        var w = bannerAd.width / DevicePixelRatio
        var h = bannerAd.height / DevicePixelRatio

        if (adsEnabled && !removeAdsBought) {
            var sbHeight = Screen.height - Screen.desktopAvailableHeight
            bannerAd.x = (app.width - w) * DevicePixelRatio / 2
            bannerAd.y = (app.height - h + sbHeight + 1) * DevicePixelRatio
        }

        else {
            bannerAd.x = app.width * 2
            bannerAd.y = app.height * 2
        }
    }

    //
    // Restores the purchases
    //
    function restorePurchases() {
        store.restorePurchases()
    }

    //
    // Tries to buy the 'remove ads' extension
    //
    function removeAds() {
        productRemoveAds.purchase()
    }

    //
    // Shows the interstitial ad
    //
    function showInterstitialAd() {
        if (interstitialAd.isLoaded && adsEnabled && !removeAdsBought)
            interstitialAd.visible = true
    }

    //
    // Registers the test devices that I use
    //
    Component.onCompleted: {
        bannerAd.addTestDevice ("4F039A153EF594B22BF1F3B75D362C1C")
        bannerAd.addTestDevice ("0695E556B27F6703BFB53D0713352020")
    }

    //
    // Locate the banner when the custom properties are changed
    //
    onAdsEnabledChanged: displayBanner()

    //
    // Locate the banner when window size is changed
    //
    Connections {
        target: app
        onWidthChanged: displayBanner()
        onHeightChanged: displayBanner()
    }

    //
    // Waits five seconds to check if the user has purchased the 'remove ads'
    // extension
    //
    Timer {
        id: timer
        interval: 5000
        onTriggered: {
            if (!removeAdsBought && Qt.platform.os === "android" || Qt.platform.os === "ios")
                adsEnabled = true
        }
    }

    //
    // Available purchase items
    //
    Store {
        id: store

        Product {
            id: productRemoveAds
            type: Product.Unlockable
            identifier: "com.alexspataru.supertac.remove_ads"

            onPurchaseSucceeded: {
                transaction.finalize()
                messageBox.text = qsTr ("Thanks for your purchase!") + Translator.dummy
                messageBox.open()

                adsEnabled = false
                removeAdsBought = true
            }

            onPurchaseFailed: {
                transition.finalize()
                messageBox.text = qsTr ("Failed to perform transaction") + Translator.dummy
                messageBox.open()
            }

            onPurchaseRestored: {
                adsEnabled = false
                removeAdsBought = true

                messageBox.text = qsTr ("Purchases restored!") + Translator.dummy
                messageBox.open()
            }

            onStatusChanged: timer.start()
        }
    }

    //
    // Used to confirm purchases
    //
    MessageDialog {
        id: messageBox
        title: app.title
        icon: StandardIcon.Information
        standardButtons: StandardButton.Close
    }

    //
    // Banner add
    //
    AdMobBanner {
        id: bannerAd
        onLoaded: displayBanner()
        Component.onCompleted: {
            visible = true
            unitId = BannerId
            size = AdMobBanner.SmartBanner
        }
    }

    //
    // Interstitial ad
    //
    AdMobInterstitial {
        id: interstitialAd
        onClosed: interstitialAd.unitId = InterstitialId
        Component.onCompleted: interstitialAd.unitId = InterstitialId
    }
}
