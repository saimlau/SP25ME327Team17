package team17Pkg;

import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.ArrayList;

public class LeaderBoard {
    Hashtable<String, Integer> names;

    public LeaderBoard(String[] lines){
        loadData(lines);
    }

    public void recordScore(String name, int score){
        if(names.containsKey(name)){
            if(names.get(name) < score) names.replace(name, score);
        } else {
            names.put(name, score);
        }
    }

    public int getNum(){
        return names.size();
    }

    public String getStr(boolean numbered){
        StringBuilder out = new StringBuilder("");
        LinkedHashMap<String, Integer> sortedBoard = new LinkedHashMap<>();
        ArrayList<Integer> list = new ArrayList<>();
        for (Map.Entry<String, Integer> entry : names.entrySet()) {
            list.add(entry.getValue());
        }
        Collections.sort(list, Collections.reverseOrder());
        for(int score : list) {
            for (Entry<String, Integer> entry : names.entrySet()) {
                if (entry.getValue().equals(score)) {
                    sortedBoard.put(entry.getKey(), score);
                }
            }
        }

        int i = 1;
        for (Entry<String, Integer> entry : sortedBoard.entrySet()) {
            String name = entry.getKey();
            if(numbered) out.append(i + ". " + name + ", " + entry.getValue() + "\n");
            else out.append(name + ", " + entry.getValue() + "\n");
            i ++;
        }
        return out.toString();
    }

    public void loadData(String[] lines) {
        this.names = new Hashtable<>();
        for (int i = 0 ; i < lines.length; i++) {
            String data = lines[i];
            if(!data.equals("")){
                names.put(data.split(", ")[0], Integer.parseInt(data.split(", ")[1]));
            }
        }
    }
}
