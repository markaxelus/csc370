"""
Soccer Data Visualization Generator
Creates visualizations for Q2, Q7, Q9, and Q10 of the soccer.sql assignment
Outputs a single PDF file: soccer_viz.pdf
"""

import os
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import numpy as np

# Read the CSV files
print("Loading data...")
# Resolve CSV paths relative to this script so it works from any CWD
base_dir = os.path.dirname(__file__)
england = pd.read_csv(os.path.join(base_dir, 'england.csv'))
france = pd.read_csv(os.path.join(base_dir, 'france.csv'))
germany = pd.read_csv(os.path.join(base_dir, 'germany.csv'))
italy = pd.read_csv(os.path.join(base_dir, 'italy.csv'))

# Create PDF to save all visualizations
pdf_filename = 'soccer_viz.pdf'
print(f"Creating visualizations in {pdf_filename}...")

with PdfPages(pdf_filename) as pdf:
    
    # ============= Q2 VISUALIZATION =============
    # Bar chart: Total goals distribution in England since 1980
    print("Creating Q2 visualization...")
    
    # Filter England data for seasons >= 1980
    # Ensure total goals exists; compute if missing
    if 'totgoal' not in england.columns and {'hgoal', 'vgoal'}.issubset(england.columns):
        england = england.copy()
        england['totgoal'] = england['hgoal'] + england['vgoal']
    england_1980 = england[england['season'] >= 1980]
    
    # Count games by total goals
    q2_data = england_1980.groupby('totgoal').size().reset_index(name='num_games')
    
    fig, ax = plt.subplots(figsize=(12, 6))
    ax.bar(q2_data['totgoal'], q2_data['num_games'], color='steelblue', edgecolor='black')
    ax.set_xlabel('Total Goals', fontsize=12, fontweight='bold')
    ax.set_ylabel('Number of Games', fontsize=12, fontweight='bold')
    ax.set_title('Q2: Distribution of Total Goals per Game in England (Since 1980)', 
                 fontsize=14, fontweight='bold', pad=20)
    ax.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    pdf.savefig(fig)
    plt.close()
    
    
    # ============= Q7 VISUALIZATION =============
    # Two bar charts: Arsenal vs other teams (home wins and away wins)
    print("Creating Q7 visualization...")
    
    # Filter England tier 1 data since 1980
    england_tier1 = england[(england['tier'] == 1) & (england['season'] >= 1980)]
    
    # Calculate home wins
    home_wins = england_tier1[england_tier1['result'] == 'H'].groupby(['home', 'visitor']).size().reset_index(name='home_wins')
    home_wins.columns = ['team1', 'team2', 'home_wins']
    
    # Calculate away wins
    away_wins = england_tier1[england_tier1['result'] == 'A'].groupby(['visitor', 'home']).size().reset_index(name='away_wins')
    away_wins.columns = ['team1', 'team2', 'away_wins']
    
    # Merge to create Wins view
    wins = pd.merge(home_wins, away_wins, on=['team1', 'team2'], how='inner')
    
    # Get Arsenal data
    arsenal_vs = wins[wins['team1'] == 'Arsenal'].copy()
    vs_arsenal = wins[wins['team2'] == 'Arsenal'].copy()
    
    # Merge Arsenal's stats with opponents' stats
    q7_data = pd.merge(
        arsenal_vs,
        vs_arsenal,
        left_on='team2',
        right_on='team1',
        suffixes=('_arsenal', '_opponent')
    )
    
    # Sort by opponent's away wins descending
    q7_data = q7_data.sort_values('away_wins_opponent', ascending=False)
    
    # Create two subplots
    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10))
    
    # Home wins comparison
    x = np.arange(len(q7_data))
    width = 0.35
    
    ax1.bar(x - width/2, q7_data['home_wins_arsenal'], width, 
            label='Arsenal Home Wins', color='crimson', edgecolor='black')
    ax1.bar(x + width/2, q7_data['home_wins_opponent'], width, 
            label='Opponent Home Wins', color='navy', edgecolor='black')
    ax1.set_xlabel('Opponent Team', fontsize=11, fontweight='bold')
    ax1.set_ylabel('Number of Home Wins', fontsize=11, fontweight='bold')
    ax1.set_title('Q7a: Arsenal Home Wins vs Opponents Home Wins (Since 1980)', 
                  fontsize=13, fontweight='bold')
    ax1.set_xticks(x)
    ax1.set_xticklabels(q7_data['team2_arsenal'], rotation=45, ha='right', fontsize=9)
    ax1.legend()
    ax1.grid(axis='y', alpha=0.3)
    
    # Away wins comparison
    ax2.bar(x - width/2, q7_data['away_wins_arsenal'], width, 
            label='Arsenal Away Wins', color='crimson', edgecolor='black')
    ax2.bar(x + width/2, q7_data['away_wins_opponent'], width, 
            label='Opponent Away Wins', color='navy', edgecolor='black')
    ax2.set_xlabel('Opponent Team', fontsize=11, fontweight='bold')
    ax2.set_ylabel('Number of Away Wins', fontsize=11, fontweight='bold')
    ax2.set_title('Q7b: Arsenal Away Wins vs Opponents Away Wins (Since 1980)', 
                  fontsize=13, fontweight='bold')
    ax2.set_xticks(x)
    ax2.set_xticklabels(q7_data['team2_arsenal'], rotation=45, ha='right', fontsize=9)
    ax2.legend()
    ax2.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    pdf.savefig(fig)
    plt.close()
    
    
    # ============= Q9 VISUALIZATION =============
    # Line chart: Average goals per season (England vs Italy)
    print("Creating Q9 visualization...")
    
    # England average total goals per season (since 1970)
    england_1970 = england[england['season'] >= 1970]
    england_avg = england_1970.groupby('season')['totgoal'].mean().reset_index()
    england_avg.columns = ['season', 'england_avg']
    
    # Italy average total goals per season (since 1970)
    # Italy table doesn't have totgoal, calculate from hgoal + vgoal
    italy_1970 = italy[italy['season'] >= 1970].copy()
    # Compute total goals for Italy if not already present
    if 'totgoal' not in italy_1970.columns and {'hgoal', 'vgoal'}.issubset(italy_1970.columns):
        italy_1970['totgoal'] = italy_1970['hgoal'] + italy_1970['vgoal']
    italy_avg = italy_1970.groupby('season')['totgoal'].mean().reset_index()
    italy_avg.columns = ['season', 'italy_avg']
    
    # Merge the two datasets
    q9_data = pd.merge(england_avg, italy_avg, on='season')
    
    fig, ax = plt.subplots(figsize=(14, 7))
    ax.plot(q9_data['season'], q9_data['england_avg'], 
            marker='o', linewidth=2, label='England', color='red', markersize=4)
    ax.plot(q9_data['season'], q9_data['italy_avg'], 
            marker='s', linewidth=2, label='Italy', color='green', markersize=4)
    ax.set_xlabel('Season', fontsize=12, fontweight='bold')
    ax.set_ylabel('Average Total Goals', fontsize=12, fontweight='bold')
    ax.set_title('Q9: Average Total Goals per Season - England vs Italy (Since 1970)\n(Testing the Catenaccio Hypothesis)', 
                 fontsize=14, fontweight='bold', pad=20)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    pdf.savefig(fig)
    plt.close()
    
    
    # ============= Q10 VISUALIZATION =============
    # Bar chart: Goal difference distribution (France vs England, tier 1, normalized)
    print("Creating Q10 visualization...")
    
    # France tier 1
    france_tier1 = france[france['tier'] == 1]
    total_france = len(france_tier1)
    france_goaldif = france_tier1.groupby('goaldif').size().reset_index(name='count')
    france_goaldif['france_games'] = france_goaldif['count'] / total_france
    france_goaldif = france_goaldif[['goaldif', 'france_games']]
    
    # England tier 1
    england_tier1_all = england[england['tier'] == 1]
    total_england = len(england_tier1_all)
    england_goaldif = england_tier1_all.groupby('goaldif').size().reset_index(name='count')
    england_goaldif['eng_games'] = england_goaldif['count'] / total_england
    england_goaldif = england_goaldif[['goaldif', 'eng_games']]
    
    # Merge the two datasets
    q10_data = pd.merge(france_goaldif, england_goaldif, on='goaldif', how='outer').fillna(0)
    q10_data = q10_data.sort_values('goaldif')
    
    fig, ax = plt.subplots(figsize=(14, 7))
    x = np.arange(len(q10_data))
    width = 0.35
    
    ax.bar(x - width/2, q10_data['france_games'], width, 
           label='France', color='blue', edgecolor='black', alpha=0.7)
    ax.bar(x + width/2, q10_data['eng_games'], width, 
           label='England', color='red', edgecolor='black', alpha=0.7)
    
    ax.set_xlabel('Goal Difference', fontsize=12, fontweight='bold')
    ax.set_ylabel('Proportion of Games (Normalized)', fontsize=12, fontweight='bold')
    ax.set_title('Q10: Normalized Goal Difference Distribution - France vs England (Tier 1)', 
                 fontsize=14, fontweight='bold', pad=20)
    ax.set_xticks(x)
    ax.set_xticklabels(q10_data['goaldif'].astype(int), rotation=45, ha='right')
    ax.legend(fontsize=11)
    ax.grid(axis='y', alpha=0.3)
    plt.tight_layout()
    pdf.savefig(fig)
    plt.close()

print(f"\nAll visualizations saved to {pdf_filename}")
print("\nGenerated visualizations:")
print("  - Q2: Total goals distribution bar chart")
print("  - Q7: Arsenal comparison bar charts (home & away wins)")
print("  - Q9: England vs Italy average goals line chart")
print("  - Q10: Goal difference distribution bar chart")
print("\nYou can now submit this PDF file with your assignment!")
