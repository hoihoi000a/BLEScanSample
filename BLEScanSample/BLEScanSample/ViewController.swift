//
//  ViewController.swift
//  BLEScanSample
//
//  Created by allion on 2020/3/20.
//  Copyright © 2020 Newman. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController , UITableViewDelegate, UITableViewDataSource,CBCentralManagerDelegate{
    @IBOutlet weak var mScanBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var centralManager:CBCentralManager? = nil
    var map:[CBPeripheral:[Int]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("This is viewDidLoad")
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("This is viewDidAppear")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("This is viewWillLayoutSubviews")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("This is viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("This is viewDidDisappear")
    }


    //    MARK: Table view data source
        // set select one item
        func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
        
        
        // set how many item in table
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return map.count
        }
        
        // set data into table
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // set cell with identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceTableViewCell", for: indexPath)
            
            // Sorting
            let dictSortByValue = map.sorted { (entry1, entry2) -> Bool in
                return (entry1.value.reduce(0,+)/entry1.value.count) > (entry2.value.reduce(0,+)/entry2.value.count)
            }
            
            let peripheral = Array(dictSortByValue)[indexPath.row].key
            let rssiArray = Array(dictSortByValue)[indexPath.row].value
            
            cell.textLabel?.text = "\(peripheral.name ?? "") / \(rssiArray)"
            
            return cell
        }
        
        
        @IBAction func mScanAtion(_ sender: Any) {
            scanBLEDevices()
        }
        
    // MARK: BLE Scanning
        // scan devices
        func scanBLEDevices(){
            
            print("Scanning")
            
            mScanBtn.setTitle("Scanning", for: .normal)
            
            // clear array
            map.removeAll()
            
            // if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
            centralManager?.scanForPeripherals(withServices: nil, options:nil)
            
            // stop scanning after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                self.stopScanForBLEDevices()
            })

        }
        
        // stop scanning
        func stopScanForBLEDevices(){
            
            print("Finish scanning")
            
            mScanBtn.setTitle("Scan", for: .normal)
            
            centralManager?.stopScan()
            
            // refresh table
            tableView.reloadData()
        }
        
    // MARK: CBCentralManagerDelegate Methods
        // get state
        func centralManagerDidUpdateState(_ central: CBCentralManager) {
            switch central.state {

                case CBManagerState.poweredOff:
                    print("CoreBluetooth BLE hardware is powered off")

                    var turnOnBTAlert = UIAlertController(title: "ALERT", message: "Please turn on Bluetooth in Settings", preferredStyle: UIAlertController.Style.alert)

                    let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (UIAlertAction) in
                    print("OK is tapped")
                    }

                    turnOnBTAlert.addAction(okAction)

                    self.present(turnOnBTAlert, animated: true, completion: nil)
                    break
                    
                case CBManagerState.unauthorized:
                    print("CoreBluetooth BLE state is unauthorized")
                    break

                case CBManagerState.unknown:
                    print("CoreBluetooth BLE state is unknown");
                    break

                case CBManagerState.poweredOn:
                    print("CoreBluetooth BLE hardware is powered on and ready")
                    scanBLEDevices()
                    break

                case CBManagerState.resetting:
                    print("CoreBluetooth BLE hardware is resetting")
                    break
                    
                case CBManagerState.unsupported:
                    print("CoreBluetooth BLE hardware is unsupported on this platform");
                    break
                    
                default:
                    print(centralManager?.state)
                    break
            }
        }
        
        // when discovery
        func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

            // add stuff into map
            if(RSSI.intValue != 127){
                if(!map.keys.contains(peripheral)){
                    map[peripheral] = [RSSI.intValue]
                }else{
                    map[peripheral]?.append(RSSI.intValue)
                }
                
                if(map[peripheral]!.count > 5){
                    map[peripheral]?.remove(at: 0)
                }
                    
            }

        }
}

