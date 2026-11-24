import { StyleSheet, Text, View } from 'react-native';
import { PublicRegisterRole } from '@arriendos/api-types';

export default function HomeScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Arriendos Bogotá D.C.</Text>
      <Text style={styles.subtitle}>
        Roles disponibles: {PublicRegisterRole.TENANT} / {PublicRegisterRole.LANDLORD}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 24,
    backgroundColor: '#ffffff',
  },
  title: {
    fontSize: 22,
    fontWeight: '700',
    color: '#111827',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#4b5563',
    textAlign: 'center',
  },
});
