import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseMission {
 const CourseMission(this.id,this.chapter,this.title,this.focus,this.concept,this.example,this.context,this.challenge,this.answer);
 final String id,chapter,title,focus,concept,example,context,challenge,answer;
}
const class12Missions=<CourseMission>[
CourseMission('b01','01','Python Revision Tour','Core language','Tokens are keywords, identifiers, literals, operators and punctuators. Variables bind names to objects. Programs use sequence, selection and iteration.','marks=86\nif marks >= 75:\n    print("Distinction")','A result portal checks marks and chooses a grade.','What does >= include?','Values equal to or greater than the limit.'),
CourseMission('b02','02','Python Revision Tour-II','Strings • lists • tuples • dictionaries','Strings are immutable. Lists are ordered and mutable. Tuples are ordered and immutable. Dictionaries map keys to values. The chapter also covers bubble and insertion sort.','names=["Ira","Dev"]\nnames.append("Mia")\nstudent={"name":"Ira","marks":91}\nprint(student["marks"])','A contact app stores names in a list and each contact as a dictionary.','Which collection stores key-value pairs?','Dictionary.'),
CourseMission('b03','03','Working with Functions','Reusable modules','Functions package reusable instructions. Parameters receive input; return sends a result back. Scope controls where names are visible. Arguments may be positional, keyword or default.','def percentage(scored, maximum=500):\n    return scored/maximum*100\nprint(percentage(425))','A school portal reuses one percentage function for every student.','Which keyword sends a result to the caller?','return.'),
CourseMission('b04','04','Using Python Libraries','Modules • packages • imports','A module is a Python file of reusable definitions. A package groups modules. import makes library tools available; the standard library supplies ready-made functions.','import math\nprint(math.sqrt(81))','Engineering and navigation tools reuse tested math functions.','What does import math provide?','Access to the math module and functions such as sqrt().'),
CourseMission('b05','05','File Handling','Persistent data','Files keep data after a program ends. open() uses modes such as r, w and a. read() retrieves data; write() stores it; with closes the file safely.','with open("scores.txt","w") as f:\n    f.write("Ira,91")','A revision app saves notes that remain after closing the app.','Which mode appends without replacing existing text?','a mode.'),
CourseMission('b06','06','Recursion','Base case • recursive case','A recursive function calls itself on a smaller problem. A base case stops calls. Without a reachable base case, recursion may continue until a runtime limit.','def factorial(n):\n    if n <= 1: return 1\n    return n*factorial(n-1)\nprint(factorial(5))','Folder traversal and divide-and-conquer algorithms can use recursion.','What prevents endless recursive calls?','A reachable base case.'),
CourseMission('b07','07','Idea of Algorithmic Efficiency','Big-O complexity','Complexity describes how resource use grows with input size. Big-O expresses an upper growth bound; compare how work scales, not only one timing.','for item in records:\n    print(item)  # one pass','A search service estimates how work grows as records increase.','A single pass over n items has what time complexity?','O(n), linear time.'),
CourseMission('b08','08','Data Visualization using Pyplot','Charts • communicate data','Matplotlib pyplot creates charts. Line charts show trends, bar charts compare categories and pie charts show parts of a whole. Titles, labels and legends improve readability.','import matplotlib.pyplot as plt\nplt.plot([1,2,3],[70,82,91])\nplt.title("Score trend")\nplt.show()','A dashboard plots weekly scores to reveal progress.','Which chart suits a time trend?','Line chart.'),
CourseMission('b09','09','Data Structures I: Linear Lists','Search • insert • delete','A linear list stores elements in sequence. Operations include traversal, searching, insertion, deletion and sorting. A two-dimensional list stores rows and columns.','grid=[[1,2],[3,4]]\nprint(grid[1][0])  # 3','A timetable or game board can be represented as a 2D list.','What is grid[1][0]?','3.'),
CourseMission('b10','10','Data Structures II: Stacks and Queues','LIFO • FIFO','A stack is Last In, First Out: push adds and pop removes the top. A queue is First In, First Out: enqueue adds at rear and dequeue removes from front.','stack=[]\nstack.append("A")\nstack.append("B")\nprint(stack.pop())','Undo history uses stack behaviour; print-job scheduling uses queue behaviour.','Which structure serves the oldest waiting item first?','Queue (FIFO).'),
CourseMission('b11','11','Computer Networks I','Devices • network types','Networks connect devices to exchange data. NIC provides network access; switches connect LAN devices; routers forward packets between networks. Networks can be classified by reach and roles.','PC -> switch -> router -> internet','A school LAN connects lab computers and routes traffic outward.','Which device forwards traffic between networks?','Router.'),
CourseMission('b12','12','Computer Networks II','Protocols • TCP/IP • DNS','Protocols define communication rules. TCP provides reliable ordered delivery; IP addresses and routes packets; DNS maps domain names to IP addresses. HTTPS protects web traffic using TLS.','Browser -> DNS lookup -> server IP -> HTTPS request','When a student opens a website, DNS resolves its name before connection.','What does DNS do?','Resolves domain names to IP addresses.'),
CourseMission('b13','13','MySQL SQL Revision Tour','Relational database','A relational database organises records in tables. Rows are records and columns are fields. SQL creates tables, inserts records and retrieves selected rows.','CREATE TABLE Student(roll_no INT PRIMARY KEY, name VARCHAR(30));\nINSERT INTO Student VALUES(101,"Ira");\nSELECT * FROM Student;','A school stores student details in structured tables.','Which SQL statement retrieves records?','SELECT.'),
CourseMission('b14','14','More on SQL','ORDER BY • aggregates • GROUP BY • HAVING','ORDER BY sorts results. COUNT, SUM, AVG, MIN and MAX aggregate values. GROUP BY forms groups; HAVING filters groups, while WHERE filters rows before grouping.','SELECT city, COUNT(*)\nFROM Student\nGROUP BY city\nHAVING COUNT(*) > 2;','An admin dashboard counts students city-wise and filters larger groups.','Which clause filters groups?','HAVING.'),
CourseMission('b15','15','Creating a Django-based Web Application','Models • views • templates • URLs','Django is a Python web framework. Models describe data; views handle requests and responses; templates render pages; URL patterns route requests.','URL -> view -> model/database\nview -> template -> response','A school portal routes a profile URL to a view that reads a model and renders a page.','Which Django layer describes database data?','Model.'),
CourseMission('b16','16','Interface Python with MySQL','Connector • cursor • execute • commit','Python connects to MySQL using a connector. A connection opens the session; a cursor executes parameterised SQL; fetchone/fetchall read results; commit saves changes.','cur.execute("SELECT name FROM Student WHERE roll_no=%s",(101,))\nrow=cur.fetchone()','A result-entry program inserts a record, commits it and reads it back.','What does commit() do?','Saves transaction changes.'),
CourseMission('b17','17','Society, Law and Ethics','Privacy • IPR • cyber safety','Responsible computing respects intellectual property, avoids plagiarism, protects privacy, recognises online fraud and cybercrime, and manages e-waste safely.','Before sharing data: check consent, minimise personal data, secure access.','A student project uses permitted data and protects account details.','What is plagiarism?','Presenting another person’s work as your own without acknowledgement.')
];

class Class12CoursePage extends StatefulWidget {
 const Class12CoursePage({super.key});
 @override State<Class12CoursePage> createState()=>_Class12CoursePageState();
}
class _Class12CoursePageState extends State<Class12CoursePage>{
 Set<String> done={};
 @override void initState(){super.initState();_load();}
 Future<void> _load()async{final p=await SharedPreferences.getInstance();if(mounted)setState(()=>done=p.getStringList('book_missions_done')?.toSet()??{});}
 Future<void> _complete(CourseMission m)async{if(done.contains(m.id))return;final p=await SharedPreferences.getInstance();final next={...done,m.id};await p.setStringList('book_missions_done',next.toList());await p.setInt('cs_xp',(p.getInt('cs_xp')??0)+30);if(mounted)setState(()=>done=next);}
 @override Widget build(BuildContext context){
  final xp=done.length*30;
  return Scaffold(appBar:AppBar(title:const Text('Class XII • Tech Quest')),body:ListView(padding:const EdgeInsets.all(16),children:[
   Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('MISSION CONTROL',style:Theme.of(context).textTheme.labelLarge),
    const SizedBox(height:8),Text(xp.toString()+' XP • '+done.length.toString()+'/'+class12Missions.length.toString()+' chapters cleared',style:Theme.of(context).textTheme.titleLarge),
    const SizedBox(height:8),LinearProgressIndicator(value:done.length/class12Missions.length),
    const SizedBox(height:6),const Text('Study a concept → inspect the code → connect it to real technology → clear the mission.')
   ]))),
   const Text('BOOK-ALIGNED CLASS XII ROADMAP',style:TextStyle(fontWeight:FontWeight.bold)),
   const SizedBox(height:8),
   ...class12Missions.map((m){
    final cleared=done.contains(m.id);
    return Card(child:ExpansionTile(
     leading:CircleAvatar(child:Text(m.chapter)),
     title:Text(m.title),subtitle:Text(m.focus),
     trailing:Icon(cleared?Icons.verified:Icons.lock_open,color:cleared?Colors.green:null),
     childrenPadding:const EdgeInsets.fromLTRB(16,0,16,16),
     expandedCrossAxisAlignment:CrossAxisAlignment.start,
     children:[
      Text('CORE CONCEPT',style:Theme.of(context).textTheme.labelLarge),
      const SizedBox(height:4),Text(m.concept),
      const SizedBox(height:10),Text('CODE / MODEL',style:Theme.of(context).textTheme.labelLarge),
      const SizedBox(height:4),Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Theme.of(context).colorScheme.inverseSurface,borderRadius:BorderRadius.circular(10)),child:SelectableText(m.example,style:TextStyle(color:Theme.of(context).colorScheme.onInverseSurface,fontFamily:'monospace',fontSize:12))),
      const SizedBox(height:10),Text('REAL TECH CONNECTION',style:Theme.of(context).textTheme.labelLarge),
      const SizedBox(height:4),Text(m.context),
      const SizedBox(height:10),Text('MISSION • +30 XP',style:Theme.of(context).textTheme.labelLarge),
      const SizedBox(height:4),Text(m.challenge),
      const SizedBox(height:6),Text('Answer key: '+m.answer,style:Theme.of(context).textTheme.bodySmall),
      const SizedBox(height:8),FilledButton.icon(onPressed:cleared?null:()=>_complete(m),icon:Icon(cleared?Icons.check:Icons.flag),label:Text(cleared?'Mission cleared':'Clear mission • +30 XP'))
     ]));
   }),
   const SizedBox(height:8),const Text('The chapter titles and sequence follow the supplied Class XII Computer Science with Python book. These are original study notes and examples, not copied page scans.')
  ]));
 }
}
