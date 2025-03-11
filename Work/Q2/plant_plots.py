import argparse
import matplotlib.pyplot as plt

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plant", required=True)
    parser.add_argument("--height", nargs='+', required=True, type=float)
    parser.add_argument("--leaf_count", nargs='+', required=True, type=float)
    parser.add_argument("--dry_weight", nargs='+', required=True, type=float)
    args = parser.parse_args()

    plant = args.plant
    h = args.height
    l = args.leaf_count
    d = args.dry_weight

    print("Plant:", plant)
    print("Heights:", h)
    print("Leaf counts:", l)
    print("Dry weights:", d)

    # 1) Scatter
    plt.figure()
    plt.scatter(h, l)
    plt.title(f"{plant} - Height vs Leaves")
    plt.savefig(f"{plant}_scatter.png")
    plt.close()

    # 2) Histogram
    plt.figure()
    plt.hist(d, bins=5, edgecolor='black')
    plt.title(f"{plant} - Dry Weight Histogram")
    plt.savefig(f"{plant}_histogram.png")
    plt.close()

    # 3) Line Plot
    plt.figure()
    weeks = [f"W{i+1}" for i in range(len(h))]
    plt.plot(weeks, h, marker='o')
    plt.title(f"{plant} Growth Over Time")
    plt.savefig(f"{plant}_lineplot.png")
    plt.close()

if __name__ == "__main__":
    main()