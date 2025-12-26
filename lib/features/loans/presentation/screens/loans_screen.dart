import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/loans_providers.dart';
import '../providers/loans_state.dart';
import '../widgets/loan_card.dart';
import '../widgets/loan_chart_widget.dart';

class LoansScreen extends ConsumerStatefulWidget {
  const LoansScreen({super.key});
  
  @override
  ConsumerState<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends ConsumerState<LoansScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(loansViewModelProvider.notifier).loadLoans());
  }
  
  @override
  Widget build(BuildContext context) {
    final loansState = ref.watch(loansViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('ঋণ হিসাব', style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: () => ref.read(loansViewModelProvider.notifier).refresh(), tooltip: 'রিফ্রেশ করুন')]),
      body: _buildBody(loansState),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _showAddLoanDialog(context), icon: const Icon(Icons.add), label: const Text('নতুন ঋণ যোগ করুন')),
    );
  }
  
  Widget _buildBody(LoansState state) {
    if (state is LoansLoading) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('ঋণের তথ্য লোড হচ্ছে...', style: TextStyle(fontSize: 16))]));
    }
    
    if (state is LoansError) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.error_outline, size: 64, color: Colors.red), const SizedBox(height: 16), Text(state.message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.black87)), const SizedBox(height: 24), ElevatedButton.icon(onPressed: () => ref.read(loansViewModelProvider.notifier).refresh(), icon: const Icon(Icons.refresh), label: const Text('আবার চেষ্টা করুন'))])));
    }
    
    if (state is LoansEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey.shade400), const SizedBox(height: 16), Text('কোনো ঋণ যোগ করা হয়নি', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500)), const SizedBox(height: 8), Text('নতুন ঋণ যোগ করতে নিচের বাটনে ক্লিক করুন', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade500))])));
    }
    
    if (state is LoansLoaded) {
      return RefreshIndicator(
        onRefresh: () async => await ref.read(loansViewModelProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(margin: const EdgeInsets.all(16), elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Column(children: [const Padding(padding: EdgeInsets.all(16), child: Text('ঋণের তুলনা', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), LoanChartWidget(loans: state.loans.take(5).toList()), const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(children: [Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.blue.shade300, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), const Text('মোট ঋণ', style: TextStyle(fontSize: 12)), const SizedBox(width: 16), Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4))), const SizedBox(width: 8), const Text('পরিশোধিত', style: TextStyle(fontSize: 12))])), const SizedBox(height: 8)])),
              const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 12), child: Text('সব ঋণ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
              ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsets.only(bottom: 80), itemCount: state.loans.length, itemBuilder: (context, index) {
                final loan = state.loans[index];
                return LoanCard(loan: loan, onTap: () => _showLoanDetails(context, loan), onDelete: () => _deleteLoan(loan.id));
              }),
            ],
          ),
        ),
      );
    }
    
    return const Center(child: Text('ঋণের তথ্য পাওয়া যায়নি'));
  }
  
  void _showAddLoanDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final purposeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    
    showDialog(context: context, builder: (context) => AlertDialog(title: const Text('নতুন ঋণ যোগ করুন'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: nameController, decoration: const InputDecoration(labelText: 'ঋণদাতার নাম *', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: amountController, decoration: const InputDecoration(labelText: 'ঋণের পরিমাণ (৳) *', border: OutlineInputBorder()), keyboardType: TextInputType.number), const SizedBox(height: 12), TextField(controller: purposeController, decoration: const InputDecoration(labelText: 'উদ্দেশ্য *', border: OutlineInputBorder())), const SizedBox(height: 12), ListTile(title: const Text('তারিখ'), subtitle: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'), trailing: const Icon(Icons.calendar_today), onTap: () async {final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now()); if (date != null) selectedDate = date;})])), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')), ElevatedButton(onPressed: () async {if (nameController.text.isEmpty || amountController.text.isEmpty || purposeController.text.isEmpty) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সব তথ্য পূরণ করুন'))); return;} final amount = double.tryParse(amountController.text); if (amount == null || amount <= 0) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক পরিমাণ লিখুন'))); return;} Navigator.pop(context); final success = await ref.read(loansViewModelProvider.notifier).addLoan(lenderName: nameController.text, amount: amount, purpose: purposeController.text, loanDate: selectedDate); if (success && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ঋণ সফলভাবে যোগ করা হয়েছে'))); else if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ঋণ যোগ করতে ব্যর্থ হয়েছে')));}, child: const Text('যোগ করুন'))]));
  }
  
  void _showLoanDetails(BuildContext context, loan) {
    final paidController = TextEditingController(text: loan.paidAmount.toString());
    
    showDialog(context: context, builder: (context) => AlertDialog(title: Text(loan.lenderName), content: Column(mainAxisSize: MainAxisSize.min, children: [_buildDetailRow('উদ্দেশ্য', loan.purpose), const SizedBox(height: 12), _buildDetailRow('মোট ঋণ', '৳${loan.amount.toStringAsFixed(0)}'), const SizedBox(height: 12), _buildDetailRow('বাকি', '৳${loan.remainingAmount.toStringAsFixed(0)}'), const SizedBox(height: 16), TextField(controller: paidController, decoration: const InputDecoration(labelText: 'পরিশোধিত পরিমাণ (৳)', border: OutlineInputBorder()), keyboardType: TextInputType.number)]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করুন')), ElevatedButton(onPressed: () async {final paid = double.tryParse(paidController.text); if (paid == null) return; Navigator.pop(context); final success = await ref.read(loansViewModelProvider.notifier).updateLoan(loanId: loan.id, paidAmount: paid); if (success && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ঋণ আপডেট করা হয়েছে'))); else if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('আপডেট করতে ব্যর্থ হয়েছে')));}, child: const Text('আপডেট করুন'))]));
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Row(children: [Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Expanded(child: Text(value, style: const TextStyle(fontSize: 16)))]);
  }
  
  Future<void> _deleteLoan(String loanId) async {
    final success = await ref.read(loansViewModelProvider.notifier).deleteLoan(loanId);
    if (success && mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ঋণ মুছে ফেলা হয়েছে'))); else if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('মুছে ফেলতে ব্যর্থ হয়েছে')));
  }
}
