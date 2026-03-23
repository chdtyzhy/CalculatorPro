import React, { useState, useEffect } from 'react';
import {
  SafeAreaView,
  StyleSheet,
  Text,
  TextInput,
  View,
  TouchableOpacity,
  ScrollView,
  Alert,
  Platform,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

// 小费百分比选项
const TIP_PERCENTAGES = [10, 15, 18, 20];

// 历史记录项类型
interface HistoryItem {
  id: string;
  billAmount: number;
  tipPercentage: number;
  numberOfPeople: number;
  tipAmount: number;
  totalAmount: number;
  perPersonAmount: number;
  date: string;
}

export default function App() {
  // 状态管理
  const [billAmount, setBillAmount] = useState<string>('');
  const [selectedTip, setSelectedTip] = useState<number>(TIP_PERCENTAGES[1]); // 默认15%
  const [customTip, setCustomTip] = useState<string>('');
  const [numberOfPeople, setNumberOfPeople] = useState<string>('1');
  const [history, setHistory] = useState<HistoryItem[]>([]);
  const [darkMode, setDarkMode] = useState<boolean>(false);

  // 计算结果
  const billNum = parseFloat(billAmount) || 0;
  const peopleNum = parseInt(numberOfPeople) || 1;
  const tipPercentage = customTip ? parseFloat(customTip) : selectedTip;
  
  const tipAmount = billNum * (tipPercentage / 100);
  const totalAmount = billNum + tipAmount;
  const perPersonAmount = totalAmount / peopleNum;

  // 加载历史记录
  useEffect(() => {
    loadHistory();
  }, []);

  const loadHistory = async () => {
    try {
      const savedHistory = await AsyncStorage.getItem('tipHistory');
      if (savedHistory) {
        setHistory(JSON.parse(savedHistory));
      }
    } catch (error) {
      console.error('加载历史记录失败:', error);
    }
  };

  const saveHistory = async () => {
    if (billNum <= 0) {
      Alert.alert('提示', '请输入有效的账单金额');
      return;
    }

    const newHistoryItem: HistoryItem = {
      id: Date.now().toString(),
      billAmount: billNum,
      tipPercentage,
      numberOfPeople: peopleNum,
      tipAmount,
      totalAmount,
      perPersonAmount,
      date: new Date().toLocaleString('zh-CN'),
    };

    const updatedHistory = [newHistoryItem, ...history.slice(0, 9)]; // 保留最近10条
    setHistory(updatedHistory);

    try {
      await AsyncStorage.setItem('tipHistory', JSON.stringify(updatedHistory));
      Alert.alert('成功', '计算结果已保存到历史记录');
    } catch (error) {
      console.error('保存历史记录失败:', error);
    }
  };

  const clearHistory = async () => {
    Alert.alert(
      '确认',
      '确定要清空历史记录吗？',
      [
        { text: '取消', style: 'cancel' },
        {
          text: '确定',
          onPress: async () => {
            setHistory([]);
            await AsyncStorage.removeItem('tipHistory');
          },
        },
      ]
    );
  };

  // 主题颜色
  const colors = darkMode ? {
    background: '#1a1a1a',
    card: '#2d2d2d',
    text: '#ffffff',
    textSecondary: '#aaaaaa',
    primary: '#4dabf7',
    border: '#444444',
  } : {
    background: '#f5f5f5',
    card: '#ffffff',
    text: '#333333',
    textSecondary: '#666666',
    primary: '#1890ff',
    border: '#dddddd',
  };

  const styles = StyleSheet.create({
    container: {
      flex: 1,
      backgroundColor: colors.background,
    },
    scrollView: {
      flex: 1,
      padding: 16,
    },
    header: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      alignItems: 'center',
      marginBottom: 24,
    },
    title: {
      fontSize: 28,
      fontWeight: 'bold',
      color: colors.text,
    },
    themeToggle: {
      padding: 8,
      borderRadius: 20,
      backgroundColor: colors.card,
    },
    themeText: {
      fontSize: 14,
      color: colors.primary,
    },
    card: {
      backgroundColor: colors.card,
      borderRadius: 12,
      padding: 20,
      marginBottom: 16,
      borderWidth: 1,
      borderColor: colors.border,
      shadowColor: '#000',
      shadowOffset: { width: 0, height: 2 },
      shadowOpacity: 0.1,
      shadowRadius: 4,
      elevation: 3,
    },
    label: {
      fontSize: 16,
      marginBottom: 8,
      color: colors.text,
    },
    input: {
      borderWidth: 1,
      borderColor: colors.border,
      borderRadius: 8,
      padding: 12,
      fontSize: 18,
      color: colors.text,
      backgroundColor: colors.background,
    },
    tipContainer: {
      flexDirection: 'row',
      flexWrap: 'wrap',
      marginTop: 8,
    },
    tipButton: {
      paddingHorizontal: 16,
      paddingVertical: 10,
      borderRadius: 20,
      marginRight: 8,
      marginBottom: 8,
      backgroundColor: colors.background,
      borderWidth: 1,
      borderColor: colors.border,
    },
    tipButtonSelected: {
      backgroundColor: colors.primary,
      borderColor: colors.primary,
    },
    tipText: {
      fontSize: 16,
      color: colors.text,
    },
    tipTextSelected: {
      color: '#ffffff',
      fontWeight: 'bold',
    },
    resultCard: {
      backgroundColor: colors.primary + '20',
      borderColor: colors.primary,
    },
    resultTitle: {
      fontSize: 18,
      fontWeight: 'bold',
      marginBottom: 12,
      color: colors.text,
    },
    resultRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      marginBottom: 8,
    },
    resultLabel: {
      fontSize: 16,
      color: colors.textSecondary,
    },
    resultValue: {
      fontSize: 18,
      fontWeight: 'bold',
      color: colors.text,
    },
    saveButton: {
      backgroundColor: colors.primary,
      paddingVertical: 14,
      borderRadius: 8,
      alignItems: 'center',
      marginTop: 16,
    },
    saveButtonText: {
      color: '#ffffff',
      fontSize: 18,
      fontWeight: 'bold',
    },
    historyTitle: {
      fontSize: 20,
      fontWeight: 'bold',
      marginTop: 24,
      marginBottom: 12,
      color: colors.text,
    },
    historyItem: {
      backgroundColor: colors.card,
      borderRadius: 8,
      padding: 12,
      marginBottom: 8,
      borderWidth: 1,
      borderColor: colors.border,
    },
    historyRow: {
      flexDirection: 'row',
      justifyContent: 'space-between',
      marginBottom: 4,
    },
    historyDate: {
      fontSize: 12,
      color: colors.textSecondary,
      marginTop: 4,
    },
    clearButton: {
      padding: 10,
      borderRadius: 6,
      backgroundColor: colors.background,
      borderWidth: 1,
      borderColor: colors.border,
      alignItems: 'center',
      marginTop: 8,
    },
    clearButtonText: {
      color: colors.textSecondary,
      fontSize: 14,
    },
  });

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.scrollView}>
        {/* 头部 */}
        <View style={styles.header}>
          <Text style={styles.title}>小费计算器</Text>
          <TouchableOpacity
            style={styles.themeToggle}
            onPress={() => setDarkMode(!darkMode)}>
            <Text style={styles.themeText}>
              {darkMode ? '☀️ 浅色' : '🌙 深色'}
            </Text>
          </TouchableOpacity>
        </View>

        {/* 账单金额 */}
        <View style={styles.card}>
          <Text style={styles.label}>账单金额</Text>
          <TextInput
            style={styles.input}
            placeholder="输入账单金额"
            placeholderTextColor={colors.textSecondary}
            keyboardType="decimal-pad"
            value={billAmount}
            onChangeText={setBillAmount}
          />
        </View>

        {/* 小费百分比 */}
        <View style={styles.card}>
          <Text style={styles.label}>小费百分比</Text>
          <View style={styles.tipContainer}>
            {TIP_PERCENTAGES.map((percentage) => (
              <TouchableOpacity
                key={percentage}
                style={[
                  styles.tipButton,
                  selectedTip === percentage && !customTip && styles.tipButtonSelected,
                ]}
                onPress={() => {
                  setSelectedTip(percentage);
                  setCustomTip('');
                }}>
                <Text
                  style={[
                    styles.tipText,
                    selectedTip === percentage && !customTip && styles.tipTextSelected,
                  ]}>
                  {percentage}%
                </Text>
              </TouchableOpacity>
            ))}
          </View>
          <TextInput
            style={[styles.input, { marginTop: 12 }]}
            placeholder="或输入自定义百分比"
            placeholderTextColor={colors.textSecondary}
            keyboardType="decimal-pad"
            value={customTip}
            onChangeText={(text) => {
              setCustomTip(text);
              if (text) setSelectedTip(0);
            }}
          />
        </View>

        {/* 人数 */}
        <View style={styles.card}>
          <Text style={styles.label}>人数（AA制）</Text>
          <TextInput
            style={styles.input}
            placeholder="输入人数"
            placeholderTextColor={colors.textSecondary}
            keyboardType="number-pad"
            value={numberOfPeople}
            onChangeText={setNumberOfPeople}
          />
        </View>

        {/* 计算结果 */}
        <View style={[styles.card, styles.resultCard]}>
          <Text style={styles.resultTitle}>计算结果</Text>
          
          <View style={styles.resultRow}>
            <Text style={styles.resultLabel}>账单金额</Text>
            <Text style={styles.resultValue}>¥{billNum.toFixed(2)}</Text>
          </View>
          
          <View style={styles.resultRow}>
            <Text style={styles.resultLabel}>小费（{tipPercentage}%）</Text>
            <Text style={styles.resultValue}>¥{tipAmount.toFixed(2)}</Text>
          </View>
          
          <View style={styles.resultRow}>
            <Text style={styles.resultLabel}>总计</Text>
            <Text style={styles.resultValue}>¥{totalAmount.toFixed(2)}</Text>
          </View>
          
          <View style={styles.resultRow}>
            <Text style={styles.resultLabel}>每人应付</Text>
            <Text style={styles.resultValue}>¥{perPersonAmount.toFixed(2)}</Text>
          </View>

          <TouchableOpacity style={styles.saveButton} onPress={saveHistory}>
            <Text style={styles.saveButtonText}>保存到历史记录</Text>
          </TouchableOpacity>
        </View>

        {/* 历史记录 */}
        {history.length > 0 && (
          <>
            <Text style={styles.historyTitle}>历史记录</Text>
            {history.map((item) => (
              <View key={item.id} style={styles.historyItem}>
                <View style={styles.historyRow}>
                  <Text style={styles.resultLabel}>账单</Text>
                  <Text style={styles.resultValue}>¥{item.billAmount.toFixed(2)}</Text>
                </View>
                <View style={styles.historyRow}>
                  <Text style={styles.resultLabel}>小费</Text>
                  <Text style={styles.resultValue}>{item.tipPercentage}% (¥{item.tipAmount.toFixed(2)})</Text>
                </View>
                <View style={styles.historyRow}>
                  <Text style={styles.resultLabel}>总计</Text>
                  <Text style={styles.resultValue}>¥{item.totalAmount.toFixed(2)}</Text>
                </View>
                <Text style={styles.historyDate}>{item.date}</Text>
              </View>
            ))}
            <TouchableOpacity style={styles.clearButton} onPress={clearHistory}>
              <Text style={styles.clearButtonText}>清空历史记录</Text>
            </TouchableOpacity>
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}