// ignore_for_file: deprecated_member_use, prefer_interpolation_to_compose_strings
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const apiBase = String.fromEnvironment('API_BASE_URL');
class AdvancedHub extends StatelessWidget {
 const AdvancedHub({super.key});
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Learning Studio')),body:ListView(padding:const EdgeInsets.all(16),children:[
  Text('Your complete CS workspace',style:Theme.of(c).textTheme.headlineSmall),
  const Text('Study, practise, review and track your learning. Cloud AI needs backend configuration.'),
  _tile(c,'Progress dashboard','Local completed-topic checklist and XP',Icons.insights,const ProgressPage()),
  _tile(c,'AI CS tutor','Ask Python, SQL and integration questions',Icons.auto_awesome,const TutorPage()),
  _tile(c,'Question scanner','Camera/gallery OCR with on-device recognition',Icons.document_scanner,const ScannerPage()),
  _tile(c,'Coding practice lab','Predict Python output and reason about SQL',Icons.terminal,const CodingPage()),
  _tile(c,'CBSE mock practice','10-question starter paper with explanations',Icons.assignment,const ExamPage()),
  _tile(c,'Daily coding missions','Complete challenges and earn XP',Icons.emoji_events,const MissionPage()),
  _tile(c,'Voice read-aloud','Listen using device text-to-speech',Icons.volume_up,const VoicePage()),
  const Info('Feature boundaries','Progress is local. AI needs backend provider configuration. Code practice predicts output but does not run arbitrary code. Mock practice is a starter set, not a full official 70-mark paper. Voice is text-to-speech; cloud sync and speech recognition are not enabled.')
 ]));
}
Widget _tile(BuildContext c,String t,String s,IconData i,Widget p)=>Card(child:ListTile(leading:CircleAvatar(child:Icon(i)),title:Text(t),subtitle:Text(s),trailing:const Icon(Icons.chevron_right),onTap:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>p))));
class Info extends StatelessWidget {const Info(this.title,this.body,{super.key});final String title,body;@override Widget build(BuildContext c)=>Card(color:Theme.of(c).colorScheme.surfaceContainerHighest,child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:Theme.of(c).textTheme.titleMedium),const SizedBox(height:5),Text(body)])));}
class Store {
 static Future<Set<String>> done()async=>(await SharedPreferences.getInstance()).getStringList('cs_done')?.toSet()??<String>{};
 static Future<int> xp()async=>(await SharedPreferences.getInstance()).getInt('cs_xp')??0;
 static Future<void> finish(String id,{int reward=10})async{final p=await SharedPreferences.getInstance();final a=p.getStringList('cs_done')??<String>[];if(!a.contains(id)){a.add(id);await p.setStringList('cs_done',a);await p.setInt('cs_xp',(p.getInt('cs_xp')??0)+reward);}}
}
class ProgressPage extends StatefulWidget{const ProgressPage({super.key});@override State<ProgressPage> createState()=>_ProgressPageState();}
class _ProgressPageState extends State<ProgressPage>{
 static const topics=< (String,String)>[('py1','Python basics'),('py2','Conditions and loops'),('py3','Strings and collections'),('py4','Functions and files'),('py5','Stack operations'),('sql1','Database and tables'),('sql2','INSERT, UPDATE, DELETE'),('sql3','SELECT and filtering'),('sql4','Aggregates and grouping'),('sql5','Joins and keys'),('int1','Python–SQL integration')];
 Set<String> completed={};int points=0;
 @override void initState(){super.initState();load();}
 Future<void> load()async{final d=await Store.done();final p=await Store.xp();final topicIds=topics.map((t)=>t.$1).toSet();if (mounted) { setState(() { completed = d.intersection(topicIds); points = p; }); }}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Progress dashboard')),body:ListView(padding:const EdgeInsets.all(16),children:[
  Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('$points XP',style:Theme.of(c).textTheme.headlineMedium),Text(completed.length.toString()+' of '+topics.length.toString()+' learning goals completed'),LinearProgressIndicator(value:completed.length/topics.length)]))),
  ...topics.map((t)=>CheckboxListTile(value:completed.contains(t.$1),title:Text(t.$2),onChanged:(v)async{if(v==true)await Store.finish(t.$1);await load();})),
  const Info('Local storage','Progress and XP stay on this device. Cloud synchronisation is not enabled.')
 ]));
}
class TutorPage extends StatefulWidget{const TutorPage({super.key,this.initial=''});final String initial;@override State<TutorPage> createState()=>_TutorPageState();}
class _TutorPageState extends State<TutorPage>{
 late final q=TextEditingController(text:widget.initial);String subject='Python',answer='Ask a question to receive a step-by-step explanation.';bool busy=false;final tts=FlutterTts();
 Future<void> ask()async{if(q.text.trim().isEmpty||busy)return;if(apiBase.isEmpty){setState(()=>answer='AI tutor is not connected. Configure API_BASE_URL and backend AI provider settings. Offline lessons still work.');return;}setState(()=>busy=true);try{final url=apiBase.replaceAll(RegExp(r'/+$'),'')+'/api/v1/tutor';final r=await http.post(Uri.parse(url),headers:const {'Content-Type':'application/json'},body:jsonEncode({'subject':subject.toLowerCase(),'question':q.text.trim()})).timeout(const Duration(seconds:45));final d=jsonDecode(r.body);if(r.statusCode!=200)throw Exception(d['detail']??'Tutor service error');setState(()=>answer=d['answer']??'No answer returned.');}catch(e){setState(()=>answer='AI tutor unavailable: '+e.toString());}finally{if(mounted)setState(()=>busy=false);}}
 @override void dispose(){q.dispose();tts.stop();super.dispose();}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('AI CS tutor')),body:ListView(padding:const EdgeInsets.all(16),children:[
  DropdownButtonFormField<String>(value:subject,items:const [DropdownMenuItem(value:'Python',child:Text('Python')),DropdownMenuItem(value:'SQL',child:Text('SQL / MySQL')),DropdownMenuItem(value:'Integration',child:Text('Python + SQL'))],onChanged:(v)=>setState(()=>subject=v??'Python')),
  const SizedBox(height:10),TextField(controller:q,minLines:3,maxLines:7,decoration:const InputDecoration(border:OutlineInputBorder(),labelText:'Your question')),
  FilledButton(onPressed:busy?null:ask,child:Text(busy?'Thinking…':'Ask tutor')),Info('Tutor explanation',answer),
  TextButton.icon(onPressed:()=>tts.speak(answer),icon:const Icon(Icons.volume_up),label:const Text('Read answer aloud'))
 ]));
}
class ScannerPage extends StatefulWidget{const ScannerPage({super.key});@override State<ScannerPage> createState()=>_ScannerPageState();}
class _ScannerPageState extends State<ScannerPage>{
 final picker=ImagePicker(),ocr=TextRecognizer(script:TextRecognitionScript.latin);final text=TextEditingController();bool busy=false;
 Future<void> scan(ImageSource source)async{setState(()=>busy=true);try{final f=await picker.pickImage(source:source,imageQuality:85);if(f!=null){final r=await ocr.processImage(InputImage.fromFilePath(f.path));text.text=r.text.isEmpty?'No readable text found.':r.text;}}catch(e){text.text='Scan failed: '+e.toString();}finally{if(mounted)setState(()=>busy=false);}}
 @override void dispose(){ocr.close();text.dispose();super.dispose();}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Question scanner')),body:ListView(padding:const EdgeInsets.all(16),children:[
  const Text('Scan a printed Python or SQL question and review the extracted text.'),
  Wrap(spacing:8,children:[FilledButton(onPressed:busy?null:()=>scan(ImageSource.camera),child:const Text('Camera')),OutlinedButton(onPressed:busy?null:()=>scan(ImageSource.gallery),child:const Text('Gallery'))]),
  if(busy)const CircularProgressIndicator(),TextField(controller:text,minLines:7,maxLines:14,decoration:const InputDecoration(border:OutlineInputBorder(),labelText:'Extracted text')),
  FilledButton(onPressed:()=>Navigator.push(c,MaterialPageRoute(builder:(_)=>TutorPage(initial:text.text))),child:const Text('Ask tutor about this text')),
  const Info('Privacy','OCR runs on-device. Text is sent to the tutor only after you choose Ask tutor.')
 ]));
}
class CodingPage extends StatefulWidget{const CodingPage({super.key});@override State<CodingPage> createState()=>_CodingPageState();}
class _CodingPageState extends State<CodingPage>{
 int i=0;int? selected;bool checked=false;
 static const tasks=< (String,String,List<String>,int,String)>[
  ('Python list output','values = [4, 7, 9]\nprint(values[1] + values[2])',['11','16','79','Error'],1,'7 + 9 = 16.'),
  ('Python loop trace','total = 0\nfor n in [2, 3, 4]:\n    total += n',['7','9','24','0'],1,'2 + 3 + 4 = 9.'),
  ('SQL filter','What does WHERE marks >= 80 select?',['Below 80','80 and above','All rows','Only NULL'],1,'The >= operator includes 80 and larger values.'),
  ('SQL COUNT','What does SELECT COUNT(*) return?',['Average','Number of rows','Largest value','Column names'],1,'COUNT(*) counts rows.')
 ];
 @override Widget build(BuildContext c){final t=tasks[i];return Scaffold(appBar:AppBar(title:const Text('Coding practice lab')),body:ListView(padding:const EdgeInsets.all(16),children:[
  DropdownButtonFormField<int>(value:i,items:List.generate(tasks.length,(n)=>DropdownMenuItem(value:n,child:Text(tasks[n].$1))),onChanged: (v) { setState(() { i = v ?? 0; selected = null; checked = false; }); }),
  Text(t.$1,style:Theme.of(c).textTheme.titleLarge),SelectableText(t.$2.replaceAll(r'\n','\n'),style:const TextStyle(fontFamily:'monospace')),
  ...t.$3.asMap().entries.map((o)=>RadioListTile<int>(value:o.key,groupValue:selected,title:Text(o.value),onChanged:checked?null:(v)=>setState(()=>selected=v))),
  FilledButton(onPressed:selected==null?null:()=>setState(()=>checked=true),child:const Text('Check prediction')),
  if(checked)Info(selected==t.$4?'Correct':'Not quite',t.$5),
  const Info('Execution status','This is an output-prediction lab, not arbitrary code execution. Live execution requires a separate isolated sandbox.')
 ]));}
}
class ExamPage extends StatefulWidget{const ExamPage({super.key});@override State<ExamPage> createState()=>_ExamPageState();}
class _ExamPageState extends State<ExamPage>{
 static const qs=< (String,List<String>,int,String)>[
  ('Immutable Python type?',['list','dict','tuple','set'],2,'Tuple is immutable.'),('Function keyword?',['func','def','return','lambda'],1,'def defines a function.'),('len([2,4,6])?',['2','3','4','6'],1,'There are three elements.'),('Create a table?',['MAKE','CREATE TABLE','NEW','INSERT'],1,'CREATE TABLE defines a table.'),('Sort query rows?',['WHERE','HAVING','ORDER BY','GROUP BY'],2,'ORDER BY sorts rows.'),('Mean aggregate?',['COUNT','AVG','MAX','SUM'],1,'AVG calculates mean.'),('Filter groups?',['WHERE','HAVING','LIMIT','DISTINCT'],1,'HAVING filters groups.'),('Save SQL changes?',['commit','fetchone','cursor','connect'],0,'commit saves a transaction.'),('Read one row?',['fetchall','fetchone','commit','execute'],1,'fetchone returns one row.'),('Primary key purpose?',['Duplicates','Unique row identity','Sort','Encrypt'],1,'A primary key uniquely identifies a row.')
 ];
 final a=<int,int>{};bool submitted=false;
 @override Widget build(BuildContext c){final score=qs.asMap().entries.where((e)=>a[e.key]==e.value.$3).length;return Scaffold(appBar:AppBar(title:const Text('CBSE mock practice')),body:ListView(padding:const EdgeInsets.all(16),children:[
  const Info('Starter paper','10 MCQs • 10 marks • suggested 15 minutes. Not a complete official 70-mark paper.'),
  ...qs.asMap().entries.map((e)=>Card(child:Padding(padding:const EdgeInsets.all(10),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text('Q'+(e.key+1).toString()+'. '+e.value.$1,style:const TextStyle(fontWeight:FontWeight.bold)),
   ...e.value.$2.asMap().entries.map((o)=>RadioListTile<int>(dense:true,value:o.key,groupValue:a[e.key],onChanged:submitted?null:(v)=>setState(()=>a[e.key]=v!),title:Text(o.value))),
   if(submitted)Text((a[e.key]==e.value.$3?'Correct. ':'Answer: '+e.value.$2[e.value.$3]+'. ')+e.value.$4)
  ])))),
  FilledButton(onPressed:a.length==qs.length&&!submitted?()=>setState(()=>submitted=true):null,child:const Text('Submit')),
  if(submitted)...[Text('Score: '+score.toString()+' / 10',style:Theme.of(c).textTheme.headlineSmall),TextButton(onPressed: () { setState(() { a.clear(); submitted = false; }); },child:const Text('Retake'))]
 ]));}
}
class MissionPage extends StatefulWidget{const MissionPage({super.key});@override State<MissionPage> createState()=>_MissionPageState();}
class _MissionPageState extends State<MissionPage>{
 static const missions=< (String,String,String)>[('m1','Output detective','Predict a Python list-indexing program.'),('m2','SQL investigator','Write SELECT with WHERE and ORDER BY.'),('m3','Database bridge','Explain cursor(), execute() and commit().')];
 Set<String> done={};int points=0;
 @override void initState(){super.initState();load();}
 Future<void> load()async{final d=await Store.done();final p=await Store.xp();if (mounted) { setState(() { done = d; points = p; }); }}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Daily coding missions')),body:ListView(padding:const EdgeInsets.all(16),children:[
  Text('$points XP total'),...missions.map((m)=>Card(child:ListTile(title:Text(m.$2),subtitle:Text(m.$3),trailing:done.contains(m.$1)?const Text('Done'):TextButton(onPressed:()async{await Store.finish(m.$1,reward:20);await load();},child:const Text('Complete')))))
 ]));
}
class VoicePage extends StatefulWidget{const VoicePage({super.key});@override State<VoicePage> createState()=>_VoicePageState();}
class _VoicePageState extends State<VoicePage>{
 final text=TextEditingController(),tts=FlutterTts();
 @override void dispose(){text.dispose();tts.stop();super.dispose();}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('Voice read-aloud')),body:ListView(padding:const EdgeInsets.all(16),children:[
  const Text('Paste a lesson or tutor answer to listen using device text-to-speech. Live speech recognition is not enabled.'),
  TextField(controller:text,minLines:5,maxLines:12,decoration:const InputDecoration(border:OutlineInputBorder(),hintText:'Paste explanation here…')),
  FilledButton(onPressed:()async{await tts.setLanguage('en-IN');await tts.speak(text.text);},child:const Text('Read aloud')),
  OutlinedButton(onPressed:()=>tts.stop(),child:const Text('Stop'))
 ]));
}
