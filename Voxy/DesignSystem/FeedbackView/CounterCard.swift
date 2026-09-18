import SwiftUI

struct CounterCard: View {
    var job: JobPosting
    var body: some View {
        VStack {
            Text("\(job.countInterview)")
                .font(Font.custom("Nunito", size: 24).weight(.bold))
                .foregroundStyle(Color(.total))
            trainingMessage
                .font(Font.custom("Nunito", size: 16).weight(.bold))
        }
        
        .accessibilityElement(children: .combine)
        .padding(20)
        .foregroundStyle(Color("PrimaryFontColor"))
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("PrimaryBlue"))
                
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("BackgroundJobCardColor"))
                    .offset(x: -5, y: -5)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color("PrimaryBlue"), lineWidth: 1)
        )
    }
    
    private var trainingMessage: some View {
        switch job.countInterview {
        case 0:
            return VStack(alignment: .center) {
                Text("ainda não")
                Text("treinou :(")
            }
            
        case 1:
           return VStack(alignment: .center) {
                Text("treino")
                Text("realizado")
            }
           
        default:
            return VStack(alignment: .center) {
                 Text("treinos")
                 Text("realizados")
             }
        }
    }
}

#Preview {
    CounterCard(job: JobPosting(title: "Dev web", companyName: "LIT", jobDescription: "NextJS, NestJS"))
}
