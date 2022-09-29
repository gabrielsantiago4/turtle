
import SwiftUI


extension Date {
   func getFormattedDate(format: String) -> String {
       
       let date = Date()
       let format = date.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss")
       
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

struct ConfigView: View {
    
    @State var peso: Double = 0
    @State var records:Array<HKWaterRecord>
    var hkStore = HKStoreManager()
    @Environment(\.presentationMode) var presentationMode

    
    func delete(at offsets: IndexSet) {
        
        for index in offsets{
            hkStore.deleteRecord(registro: records[index]) { _, _, error in
                
            }
       }
    }
    
    
    var body: some View {
        List{
//            Section {
//                HStack{
//                    Text("Peso")
//                    Spacer()
//                    TextField("peso", value: $peso, format: .number)
//                }
//                HStack{
//                    Text("Meta Diária ")
//                    Spacer()
//                    let meta = (peso * 0.033).formatted(.number.precision(.fractionLength(2)))
//                    Text("\(meta) L")
//                        .foregroundColor(.gray)
//                }
//            } header: {
//                Text("meta de água diária")
//            }
            
            Section {
                
               
                ForEach(self.records, id: \.id) { record in
                    
                    HStack{
                        Text( String(format: "%.1f ml",record.sizeML))
           
                    }
                    
                }.onDelete(perform: delete)
            } header: {
                Text("Registros")
            }
            
            Button("Sair") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(.red)
            
 

        }
        .listStyle(.insetGrouped)
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(records: [])
        
        
    }
}
